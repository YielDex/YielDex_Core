
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC4626} from "@solmate/mixins/ERC4626.sol";

import {ILendingVault} from "./Interfaces/ILendingVault.sol";
import {IOrderExecutor} from "./Interfaces/IOrderExecutor.sol";
import {IOrderBook, OrderDatas} from "./Interfaces/IOrderBook.sol";

contract YielDexLiteProxy {

    address public admin;
    IOrderBook public orderBook;
    IOrderExecutor public orderExecutor;
    ILendingVault public lendingVault;

    constructor() {
        admin = msg.sender;
    }

    function setAdmin(address _admin) external {
        require(msg.sender == admin, "YielDexLiteProxy: Only admin can set admin");
        admin = _admin;
    }

    function setOrderBook(address _orderBook) external {
        require(msg.sender == admin, "YielDexLiteProxy: Only admin can set orderBook");
        orderBook = IOrderBook(_orderBook);
    }

    function setOrderExecutor(address _orderExecutor) external {
        require(msg.sender == admin, "YielDexLiteProxy: Only admin can set orderExecutor");
        orderExecutor = IOrderExecutor(payable(_orderExecutor));
    }

    function setLendingVault(address _lendingVault) external {
        require(msg.sender == admin, "YielDexLiteProxy: Only admin can set lendingVault");
        lendingVault = ILendingVault(_lendingVault);
    }

    function createOrder(uint price, uint amount, ERC4626 _strategyVault, address _tokenOut) external returns (uint) {
        require(address(orderBook) != address(0), "YielDexLiteProxy: OrderBook not set");
        // Create order
        return orderBook.createOrder(price, amount, _strategyVault, _tokenOut);
    }

    function getOrder(uint _orderNonce) external view returns (OrderDatas memory) {
        require(address(orderBook) != address(0), "YielDexLiteProxy: OrderBook not set");
        return orderBook.getOrder(_orderNonce);
    }

    function setPrice(uint256 price) external {
        require(address(orderExecutor) != address(0), "YielDexLiteProxy: OrderExecutor not set");
        orderExecutor.setPrice(price);
    }

    function getCurrentPrice() external view returns (uint256) {
        require(address(orderExecutor) != address(0), "YielDexLiteProxy: OrderExecutor not set");
        return orderExecutor.price();
    }

}