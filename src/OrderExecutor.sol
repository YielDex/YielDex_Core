// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {OpsReady} from "@gelato/integrations/OpsReady.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {ISwapRouter} from "@v3-periphery/interfaces/ISwapRouter.sol";
import {OrderBook} from "./OrderBook.sol";
import {LendingVault} from './LendingVault.sol';

contract OrderExecutor is OpsReady {

    uint public price; // temporary, testing purposes only
    address public deployer;

    OrderBook public orderBook;
    ISwapRouter public immutable swapRouter;
    LendingVault public lendingVault;

    event OrderDone(string, uint256);

    modifier onlyDeployer {
        require(msg.sender == deployer, "Not allowed address.");
        _; // Continue the execution of the function called
    }

    constructor(address _ops, address _taskCreator, address _swapRouter) OpsReady(_ops, _taskCreator) {
        price = 100; // arbitrary price for testing
        deployer = msg.sender;
        orderBook = OrderBook(_taskCreator);
        swapRouter = ISwapRouter(_swapRouter);
    }

    function setPrice(uint _price) external {
        price = _price;
    }

    // Used to be funded in native token
    receive() external payable {}

    function setLendingVault(address _lendingVault) external onlyDeployer {
        lendingVault = LendingVault(_lendingVault);
    }

    function executeOrder(uint orderNonce) external onlyDedicatedMsgSender {
        require(orderBook.getOrder(orderNonce).isExecuted == false, "Order already executed."); // check if order is already executed
        require(orderBook.getOrder(orderNonce).price == price, "Price is not the same as the one in the order."); // double check the price

        // execute order with orderNonce here
        uint256 amountWithdrawed = lendingVault.withdraw(orderNonce);

        // Approving the appropriate amount that uniswap is gonna take on order to make the swap
        ERC4626(orderBook.getOrder(orderNonce).strategyVault).asset().approve(address(swapRouter), amountWithdrawed);
        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(ERC4626(orderBook.getOrder(orderNonce).strategyVault).asset()),
                tokenOut: orderBook.getOrder(orderNonce).tokenOut,
                fee: 3000, // For this example, we will set the pool fee to 0.3%.
                recipient: orderBook.getOrder(orderNonce).user,
                deadline: block.timestamp,
                amountIn: amountWithdrawed,
                amountOutMinimum: 0, // NOT IN PRODUCTION
                sqrtPriceLimitX96: 0 // NOT IN PRODUCTION
            });

        // The call to `exactInputSingle` executes the swap.
        swapRouter.exactInputSingle(params);

        orderBook.setExecuted(orderNonce);
        emit OrderDone("order_executed", orderNonce);
        
        (uint256 fee, address feeToken) = _getFeeDetails();

        // Transfer the fee to the Gelato Network
        if (payable(this).balance != 1000000000000000000000 /*Only for testing remove that in production*/) _transfer(fee, feeToken);
    }

    function checker(uint orderNonce) external view returns (bool canExec, bytes memory execPayload) {
        canExec = orderBook.getOrder(orderNonce).price == price; // The condition that needs to be true for the task to be executed, you can filter the condition with the orderId
        execPayload = abi.encodeCall(OrderExecutor.executeOrder, orderNonce); // The function that you want to call on the contract
    }

}
