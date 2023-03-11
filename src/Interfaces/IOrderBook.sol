// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {OrderExecutor} from "../OrderExecutor.sol";

struct OrderDatas {
    address user;
    uint256 price;
    uint256 amount;
    address strategyVault;
    address tokenOut;
    bytes32 orderId;
    bool isExecuted;
}

interface IOrderBook {
    event construct(string, address);
    event orderCreated(string, uint256);

    function setOrderExecutor(OrderExecutor _orderExecutorAddress) external;

    function setLendingVault(address _lendingVaultAddress) external;

    function createOrder(uint price, uint amount, ERC4626 _strategyVault, address _tokenOut) external returns (uint);

    function cancelOrder(uint _orderNonce) external;
    
    function setExecuted(uint _orderNonce) external;

    function getOrder(uint _orderNonce) external view returns (OrderDatas memory);

    function getExecutorAddress() external view returns (address);

}


