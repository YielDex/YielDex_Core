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
import {WETH9} from "./external/WETH9.sol";

import {OrderBook} from "../src/Orderbook.sol";
import {OrderExecutor} from "../src/OrderExecutor.sol";
import {LendingVault} from "../src/LendingVault.sol";


contract CreateOrderTest is Test {

    // Main contracts
    OrderBook orderbook;
    OrderExecutor orderExecutor;
    LendingVault lendingVault;

    // External contracts
    ERC4626 underleyingAssetVault;

    function test_Deploy() public {
        // Deploy OrderBook
        orderbook = new OrderBook(vm.envAddress("OPS_MAINNET"));

        // Deploy OrderExecutor
        orderExecutor = new OrderExecutor(vm.envAddress("OPS_MAINNET"), address(orderbook), vm.envAddress("SwapRouter_MAINNET"));

        // Set OrderBook's executor
        orderbook.setOrderExecutor(orderExecutor);

        // Deploy LendingVault
        lendingVault = new LendingVault(address(orderbook));

        // Set OrderBook's lendingVault
        orderbook.setLendingVault(address(lendingVault));

        // Set OrderExecutor's lendingVault
        orderExecutor.setLendingVault(address(lendingVault));
    }

    function test_ERC4626CreationForCompatibleAsset() public {
        IPoolAddressesProvider aavePoolAddressesProvider = IPoolAddressesProvider(vm.envAddress("IPoolAddressesProvider_MAINNET"));
        IPool aavePool = IPool(aavePoolAddressesProvider.getPool());
        AaveV3ERC4626Factory aaveFactory = new AaveV3ERC4626Factory(aavePool, address(0x0), IRewardsController(address(0x0)));

        // Create ERC4626 for USDC
        ERC20 underleyingAsset = ERC20(vm.envAddress("USDC_MAINNET"));
        underleyingAssetVault = aaveFactory.createERC4626(underleyingAsset);

        assertEq(address(underleyingAssetVault.asset()), address(underleyingAsset));
    }

    function test_getUSDC() public {
        // Define the USDC token
        ERC20 underleyingAsset = ERC20(vm.envAddress("USDC_MAINNET"));
        uint256 underleyingAssetAmountBeforeSwap = underleyingAsset.balanceOf(msg.sender);

        // Give 100 ethers to the address that is gonna pass an order
        hoax(msg.sender, 10000000000000000000);
        // Wrap 100 ethers into WETH
        WETH9 weth = WETH9(payable(vm.envAddress("WETH_MAINNET")));
        // Give 100 ethers to the address that is gonna give WETH to the sender
        weth.deposit{value : 10000000000000000000}();
        uint256 wethBalance = weth.balanceOf(msg.sender);
        assertEq(wethBalance, 10000000000000000000);

        // Swap 100 WETH for USDC
        ISwapRouter swapRouter = ISwapRouter(vm.envAddress("SwapRouter_MAINNET"));
        // Approving the appropriate amount that uniswap is gonna take on order to make the swap
        weth.approve(vm.envAddress("SwapRouter_MAINNET"), weth.balanceOf(msg.sender));
        ERC20(vm.envAddress("WETH_MAINNET")).approve(vm.envAddress("SwapRouter_MAINNET"), weth.balanceOf(msg.sender));;
        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: vm.envAddress("WETH_MAINNET"),
                tokenOut: vm.envAddress("USDC_MAINNET"),
                fee: 3000, // For this example, we will set the pool fee to 0.3%.
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: weth.balanceOf(msg.sender),
                amountOutMinimum: 0, // NOT IN PRODUCTION
                sqrtPriceLimitX96: 0 // NOT IN PRODUCTION
            });

        // The call to `exactInputSingle` executes the swap.
        swapRouter.exactInputSingle(params);

        // Check that the swap was successful
        require(underleyingAsset.balanceOf(msg.sender) > underleyingAssetAmountBeforeSwap, "Swap failed");
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
