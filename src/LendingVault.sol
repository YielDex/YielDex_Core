// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {AaveV3ERC4626Factory} from "@yield-daddy/src/aave-v3/AaveV3ERC4626Factory.sol";
import {IPoolAddressesProvider} from "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@yield-daddy/src/aave-v3/external/IPool.sol";
import {IRewardsController} from "@yield-daddy/src/aave-v3/external/IRewardsController.sol";
import {OrderBook} from "./OrderBook.sol";

contract LendingVault {

    AaveV3ERC4626Factory public immutable aaveFactory;
    IPool public immutable aavePool;
    IPoolAddressesProvider public immutable aavePoolAddressesProvider;

    address public immutable orderBookAddress;

    // In the future, there will be a mapping for each strategies for one asset rather than this one
    mapping(ERC20 => ERC4626) public erc4626s;
    mapping(uint256 => uint256) public orderShares;
    
    event Shares(uint256 shares);

    constructor(address _iPoolAddressesProviderAddress, address _temporaryTokenAddress, address _orderBookAddress) {
        orderBookAddress = _orderBookAddress;
        aavePoolAddressesProvider = IPoolAddressesProvider(_iPoolAddressesProviderAddress);
        aavePool = IPool(aavePoolAddressesProvider.getPool());
        //rewardsController = IRewardsController(aavePoolAddressesProvider.getRewardsController());
        aaveFactory = new AaveV3ERC4626Factory(aavePool, address(0x0), IRewardsController(address(0x0)));

        // testAsset that we want to include from from start
        ERC20 underleyingAsset = ERC20(_temporaryTokenAddress);
        erc4626s[underleyingAsset] = aaveFactory.createERC4626(underleyingAsset);
    }

    function deposit(address tokenAddress, uint256 _amount, uint256 orderNonce) external {
        ERC20(tokenAddress).approve(address(erc4626s[ERC20(tokenAddress)]), _amount);
        orderShares[orderNonce] = erc4626s[ERC20(tokenAddress)].deposit(_amount, address(this));
    }

    function withdraw(address tokenAddress, uint256 orderNonce) external returns (uint256) {
        erc4626s[ERC20(tokenAddress)].approve(address(erc4626s[ERC20(tokenAddress)]), orderShares[orderNonce]);
        uint256 amount = erc4626s[ERC20(tokenAddress)].redeem(orderShares[orderNonce], address(this), address(this));
        ERC20(tokenAddress).transfer(OrderBook(orderBookAddress).getExecutorAddress(), amount);
        return amount;
    }

}