// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "@forge-std/Script.sol";
import {OrderBook} from "../src/OrderBook.sol";
import {OrderExecutor} from "../src/OrderExecutor.sol";
import {LendingVault} from "../src/LendingVault.sol";

contract DeployScript is Script {
    //function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy OrderBook
        OrderBook orderBook = new OrderBook(vm.envAddress("OPS_MUMBAI"));

        // Deploy OrderExecutor
        OrderExecutor orderExecutor = new OrderExecutor(vm.envAddress("OPS_MUMBAI"), address(orderBook), vm.envAddress("SwapRouter_MUMBAI"));

        // Set OrderBook's executor
        orderBook.setOrderExecutor(orderExecutor);

        // Deploy LendingVault
        LendingVault lendingVault = new LendingVault(orderBook);

        // Set OrderBook's lendingVault
        orderBook.setLendingVault(address(lendingVault));

        // Set OrderExecutor's lendingVault
        orderExecutor.setLendingVault(address(lendingVault));

        vm.stopBroadcast();
    }
}