// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./gelato/Types.sol";
import "./OrderExecutor.sol";
import "./gelato/OpsTaskCreator.sol";
import './LendingVault.sol';

struct OrderDatas {
    address user;
    uint256 price;
    uint256 amount;
    address tokenIn;
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

    function setOrderExecutor(OrderExecutor _orderExecutorAddress) public onlyAdmin {
        orderExecutor = _orderExecutorAddress;
    }

    function setLendingVault(address _lendingVaultAddress) public onlyAdmin {
        lendingVault = LendingVault(_lendingVaultAddress);
    } 

    function createOrder(uint price, uint amount, address _tokenIn, address tokenOut) external returns (uint) {
        IERC20 TokenIn = IERC20(_tokenIn);

        // The user needs to approve this contract for the appropriate amount
        TokenIn.transferFrom(msg.sender, address(this), amount);

        bytes memory execData = abi.encodeCall(orderExecutor.executeOrder, (orderNonce));

        ModuleData memory moduleData = ModuleData({
            modules: new Module[](3),
            args: new bytes[](3)
        });

        moduleData.modules[0] = Module.RESOLVER;
        moduleData.modules[1] = Module.PROXY;
        moduleData.modules[2] = Module.SINGLE_EXEC;

        moduleData.args[0] = _resolverModuleArg(address(orderExecutor), abi.encodeCall(orderExecutor.checker, (orderNonce)));
        moduleData.args[1] = _proxyModuleArg();
        moduleData.args[2] = _singleExecModuleArg();

        bytes32 orderId = ops.createTask(
            address(orderExecutor), // contract to execute
            execData, // function to execute
            moduleData,
            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
        );

        orders[orderNonce] = OrderDatas(msg.sender, price, amount, _tokenIn, tokenOut, orderId, false);

        // Transfer tokens to the vault
        TokenIn.transfer(address(lendingVault), amount); // approval needed to be able to swap liquidity
        lendingVault.deposit(_tokenIn, amount, orderNonce); // depositing liquidity into the vault

        orderNonce++;

        emit orderCreated("orderNonce", orderNonce);

        return orderNonce;
    }

    function cancelOrder(uint _orderNonce) external onlyAdmin {
        ops.cancelTask(orders[_orderNonce].orderId);
    }
    
    function setExecuted(uint _orderNonce) external {
        require(msg.sender == address(orderExecutor), "Only the executor can set the order as executed");
        orders[_orderNonce].isExecuted = true;
    }

    function getOrder(uint _orderNonce) public view returns (OrderDatas memory) {
        return orders[_orderNonce];
    }

    function getExecutorAddress() public view returns (address) {
        return address(orderExecutor);
    }

}


