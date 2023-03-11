// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {AaveV3ERC4626Factory} from "@yield-daddy/src/aave-v3/AaveV3ERC4626Factory.sol";
import {IPoolAddressesProvider} from "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@yield-daddy/src/aave-v3/external/IPool.sol";
import {IRewardsController} from "@yield-daddy/src/aave-v3/external/IRewardsController.sol";
import {OrderBook, OrderDatas} from "./OrderBook.sol";

contract LendingVault {

    OrderBook public immutable orderBook;

    // One order nonce gives you -> one amount of shares
    mapping(uint256 => uint256) public orderShares;

    constructor(address _orderBook) {
        orderBook = OrderBook(_orderBook);
    }

    function deposit(uint256 orderNonce) external {
        OrderDatas memory order = orderBook.getOrder(orderNonce); // Get the order
        ERC4626 _strategyVault = ERC4626(order.strategyVault); // Get the vault
        _strategyVault.asset().approve(address(_strategyVault), order.amount); // Approve the vault to get the asset
        orderShares[orderNonce] = _strategyVault.deposit(order.amount, address(this)); // Deposit the asset into the vault
    }

    function withdraw(uint256 orderNonce) external returns (uint256) {
        OrderDatas memory order = orderBook.getOrder(orderNonce); // Get the order
        ERC4626 _strategyVault = ERC4626(order.strategyVault); // Get the vault
        _strategyVault.approve(address(_strategyVault), orderShares[orderNonce]); // Approve the vault to get back the shares
        uint256 amount = _strategyVault.redeem(orderShares[orderNonce], address(this), address(this)); // Redeem the shares
        _strategyVault.asset().transfer(orderBook.getExecutorAddress(), amount); // Transfer the asset to the executor in order to swap it
        return amount; // Return the amount of asset withdrawed
    }

}