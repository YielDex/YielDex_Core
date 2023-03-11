// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import {Test} from "@forge-std/Test.sol";

import {IPoolAddressesProvider} from "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@yield-daddy/src/aave-v3/external/IPool.sol";
import {AaveV3ERC4626Factory} from "@yield-daddy/src/aave-v3/AaveV3ERC4626Factory.sol";
import {IRewardsController} from "@yield-daddy/src/aave-v3/external/IRewardsController.sol";
import {ISwapRouter} from "@v3-periphery/interfaces/ISwapRouter.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";

import {OrderBook} from "../src/Orderbook.sol";
import {OrderExecutor} from "../src/OrderExecutor.sol";
import {LendingVault} from "../src/LendingVault.sol";


contract CreateOrderTest is Test {

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
        deal(vm.envAddress("USDC_MAINNET"), msg.sender, 100000000000, true);
        require(ERC20(vm.envAddress("USDC_MAINNET")).balanceOf(msg.sender) == 100000000000, "Not enough USDC");

        // Approve the orderbook to spend the 100000 usdc
        ERC20(vm.envAddress("USDC_MAINNET")).approve(address(orderBook), 100000000000);

        // Create an order
        orderNonce = orderBook.createOrder(123, 1, underleyingAssetVault, vm.envAddress("WETH_MAINNET"));

        // Check if the order is created
        //assertEq(orderBook.getOrder(orderNonce).user, msg.sender, "Order is not created");
    }

    function testFail_OrderNotPassed() internal {
        // Check if the order is passed
        assertEq(orderBook.getOrder(orderNonce).isExecuted, true, "Order is not passed");
    }
/*
    function testFail_Subtract43() public {
        testNumber = 43;
        assertEq(testNumber, 42);
    }

    function test_orderCreation() public {
        
    }
    */
}
