// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {OpsTaskCreator} from "@gelato/integrations/OpsTaskCreator.sol";
import {ModuleData, Module} from "@gelato/integrations/Types.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {OrderExecutor} from "./OrderExecutor.sol";
import {LendingVault} from './LendingVault.sol';

struct OrderDatas {
    address user;
    uint256 price;
    uint256 amount;
    address strategyVault;
    address tokenOut;
    bytes32 orderId;
    bool isExecuted;
}

contract OrderBook is OpsTaskCreator {
    mapping (uint => OrderDatas) internal orders; // returns order data
    uint internal orderNonce;
    address internal admin;
    OrderExecutor internal orderExecutor;
    LendingVault internal lendingVault;
    event construct(string, address);
    event orderCreated(string, uint256);

    modifier onlyAdmin {
        require(msg.sender == admin, "Not allowed address.");
        _; // Continue the execution of the function called
    }

    constructor(address _opsAddress) OpsTaskCreator(_opsAddress, address(this)) {
        admin = msg.sender;
    }

    function setOrderExecutor(OrderExecutor _orderExecutorAddress) external onlyAdmin {
        orderExecutor = _orderExecutorAddress;
    }

    function setLendingVault(address _lendingVaultAddress) external onlyAdmin {
        lendingVault = LendingVault(_lendingVaultAddress);
    } 

    function createOrder(uint price, uint amount, ERC4626 _strategyVault, address _tokenOut) external returns (uint) {

        // The user needs to approve this contract for the appropriate amount
        _strategyVault.asset().transferFrom(msg.sender, address(this), amount);

        // The function that will be executed by the executor to execute this specific order
        bytes memory execData = abi.encodeCall(orderExecutor.executeOrder, (orderNonce));

        // The modules that will be used to execute the order
        ModuleData memory moduleData = ModuleData({
            modules: new Module[](3),
            args: new bytes[](3)
        });

        moduleData.modules[0] = Module.RESOLVER;
        moduleData.modules[1] = Module.PROXY;
        moduleData.modules[2] = Module.SINGLE_EXEC;

        // The resolver module will check if the order is ready to be executed
        moduleData.args[0] = _resolverModuleArg(address(orderExecutor), abi.encodeCall(orderExecutor.checker, (orderNonce)));
        // The proxy will be a whitelisted gelato node authorized to execute the order
        moduleData.args[1] = _proxyModuleArg();
        // There will be only one execution of this order
        moduleData.args[2] = _singleExecModuleArg();

        bytes32 orderId = ops.createTask(
            address(orderExecutor), // contract to execute
            execData, // function to execute
            moduleData, // modules to use
            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE // ETH address to pay for the execution
        );

        // Save the order data
        orders[orderNonce] = OrderDatas(msg.sender, price, amount, address(_strategyVault), _tokenOut, orderId, false);

        // Transfer tokens to the vault
        _strategyVault.asset().transfer(address(lendingVault), amount); // approval needed to be able to swap liquidity
        lendingVault.deposit(orderNonce); // depositing liquidity into the vault

        orderNonce++; // increment the order nonce for the next order

        emit orderCreated("orderNonce", orderNonce);

        return orderNonce - 1; // return the order nonce
    }

    function cancelOrder(uint _orderNonce) external onlyAdmin {
        ops.cancelTask(orders[_orderNonce].orderId);
    }
    
    function setExecuted(uint _orderNonce) external {
        require(msg.sender == address(orderExecutor), "Only the executor can set the order as executed");
        orders[_orderNonce].isExecuted = true;
    }

    function getOrder(uint _orderNonce) external view returns (OrderDatas memory) {
        return orders[_orderNonce];
    }

    function getExecutorAddress() external view returns (address) {
        return address(orderExecutor);
    }

}


