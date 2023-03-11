// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import {Test} from "@forge-std/Test.sol";

import {IPoolAddressesProvider} from "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@yield-daddy/src/aave-v3/external/IPool.sol";
import {AaveV3ERC4626Factory} from "@yield-daddy/src/aave-v3/AaveV3ERC4626Factory.sol";
import {IRewardsController} from "@yield-daddy/src/aave-v3/external/IRewardsController.sol";

import {OrderBook} from "../src/Orderbook.sol";
import {OrderExecutor} from "../src/OrderExecutor.sol";
import {LendingVault} from "../src/LendingVault.sol";


contract CreateOrderTest is Test {

    OrderBook orderbook;
    OrderExecutor orderExecutor;
    LendingVault lendingVault;

    function setUp() public {
        // Deploy OrderBook
        orderbook = new OrderBook(vm.envAddress("OPS_MUMBAI"));

        // Deploy OrderExecutor
        orderExecutor = new OrderExecutor(vm.envAddress("OPS_MUMBAI"), address(orderbook), vm.envAddress("SwapRouter_MUMBAI"));

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
        IPoolAddressesProvider aavePoolAddressesProvider = IPoolAddressesProvider(vm.envAddress("IPoolAddressesProvider_MUMBAI"));
        IPool aavePool = IPool(aavePoolAddressesProvider.getPool());
        AaveV3ERC4626Factory aaveFactory = new AaveV3ERC4626Factory(aavePool, address(0x0), IRewardsController(address(0x0)));
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


