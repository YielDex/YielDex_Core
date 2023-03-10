// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import {Test, console, console2} from "@forge-std/Test.sol";

import {IPoolAddressesProvider} from "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@yield-daddy/src/aave-v3/external/IPool.sol";
import {AaveV3ERC4626Factory} from "@yield-daddy/src/aave-v3/AaveV3ERC4626Factory.sol";
import {IRewardsController} from "@yield-daddy/src/aave-v3/external/IRewardsController.sol";
import {ISwapRouter} from "@v3-periphery/interfaces/ISwapRouter.sol";
import {IOpsProxyFactory} from "@gelato/integrations/Types.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";

import {OrderBook} from "../src/Orderbook.sol";
import {OrderExecutor} from "../src/OrderExecutor.sol";
import {LendingVault} from "../src/LendingVault.sol";


contract YielDex is Test {

    // Main contracts
    OrderBook orderBook;
    OrderExecutor orderExecutor;
    LendingVault lendingVault;

    // External contracts
    ERC4626 underleyingAssetVault;

    // Data
    uint256 orderNonce;

    function setUp() public {
        deploy();
    }

    function deploy() internal {
        // Deploy OrderBook
        orderBook = new OrderBook(vm.envAddress("OPS_MAINNET"));

        // Deploy OrderExecutor
        orderExecutor = new OrderExecutor(vm.envAddress("OPS_MAINNET"), address(orderBook), vm.envAddress("SwapRouter_MAINNET"));

        // Set OrderBook's executor
        orderBook.setOrderExecutor(orderExecutor);

        // Deploy LendingVault
        lendingVault = new LendingVault(address(orderBook));

        // Set OrderBook's lendingVault
        orderBook.setLendingVault(address(lendingVault));

        // Set OrderExecutor's lendingVault
        orderExecutor.setLendingVault(address(lendingVault));
    }

    function ERC4626CreationForCompatibleAsset(address tokenIn) internal {
        IPoolAddressesProvider aavePoolAddressesProvider = IPoolAddressesProvider(vm.envAddress("IPoolAddressesProvider_MAINNET"));
        IPool aavePool = IPool(aavePoolAddressesProvider.getPool());
        AaveV3ERC4626Factory aaveFactory = new AaveV3ERC4626Factory(aavePool, address(0x0), IRewardsController(address(0x0)));

        // Create ERC4626 for USDC
        ERC20 underleyingAsset = ERC20(tokenIn);
        underleyingAssetVault = aaveFactory.createERC4626(underleyingAsset);

        assertEq(address(underleyingAssetVault.asset()), address(underleyingAsset), "ERC4626 is not created for tokenIn asset");
    }

    function test_CreateUSDCToWETHOrder() public {
        ERC4626CreationForCompatibleAsset(vm.envAddress("USDC_MAINNET"));

        // Give 100000 usdc to the address that is gonna pass an order
        deal(vm.envAddress("USDC_MAINNET"), address(this), 100000000000, true);
        require(ERC20(vm.envAddress("USDC_MAINNET")).balanceOf(address(this)) == 100000000000, "Not enough USDC");

        // Approve the orderbook to spend the 100000 usdc
        ERC20(vm.envAddress("USDC_MAINNET")).approve(address(orderBook), 100000000000);

        // Create an order
        orderNonce = orderBook.createOrder(123, 100000000000, underleyingAssetVault, vm.envAddress("WETH_MAINNET"));

        // Check if the order is created
        assertEq(orderBook.getOrder(orderNonce).user, address(this), "Order is not created");

        // Check that the order is not executed
        assertFalse(orderBook.getOrder(orderNonce).isExecuted);
    }

    function test_triggerOrders() public {
        // Recreate the order
        test_CreateUSDCToWETHOrder();

        // Fund the OrderExecutor with some eth
        hoax(address(orderExecutor), 1000000000000000000000);

        // Trigger the order condition
        orderExecutor.setPrice(123);

        // Get the address of the gelato executor
        address dedicatedMsgSender;
        address OPS_PROXY_FACTORY = 0xC815dB16D4be6ddf2685C201937905aBf338F5D7;
        (dedicatedMsgSender, ) = IOpsProxyFactory(OPS_PROXY_FACTORY).getProxyOf(
            address(orderBook)
        );

        // Get the balance of WETH before the order is executed
        uint256 wethBalanceBeforeOrderExecuted = ERC20(vm.envAddress("WETH_MAINNET")).balanceOf(address(this));

        // We are now impersonating the address of the gelato executor
        vm.startPrank(dedicatedMsgSender);
        // Trigger the order
        orderExecutor.executeOrder(orderNonce);
        vm.stopPrank();

        // Get the balance of WETH after the order is executed
        uint256 wethBalanceAfterOrderExecuted = ERC20(vm.envAddress("WETH_MAINNET")).balanceOf(address(this));

        // Check that the order is executed
        assertTrue(orderBook.getOrder(orderNonce).isExecuted);
        assertGe(wethBalanceAfterOrderExecuted, wethBalanceBeforeOrderExecuted);

        console.logString("WETH balance got with order execution");
        console.logUint((wethBalanceAfterOrderExecuted-wethBalanceBeforeOrderExecuted)/(10**18)); // Human can verify that the amount is correct
    }

    /*
    function testFail_OrderNotPassed() public {
    }
    */

}
