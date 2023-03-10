## **Introduction**

Welcome to **YielDex** protocol! This project enables users to create on-chain EVM strategies for liquidity optimization. By constructing their own complex strategies with specific parameters, users can autonomously execute on-chain orders while optimizing their liquidity in `ERC4626` vaults.

### **Current feature, current uses cases**
"*`While your order is pending, your liquidity is working`* "  
- **What the project does currently:**  
In the current implementation, you can create on-chain limit orders that are executed on-chain. While they are pending, the liquidity is put to work on the `ERC4626` vault of your choice (even your).  
Once the order execution condition is reached, your liquidity is retrieved from the vault, swapped, and sent back to the user in the same block.

- **What are the uses cases of the current implementation:**  
    1. **Trade while your liquidity is working:**  
    Traders can create limit orders that automatically execute when certain market conditions are met. By putting their liquidity to work on a chosen `ERC4626` vault while the order is pending, traders can earn additional yield on their funds until the order is executed.  

    2. **Hedge yourself while lending your liquidity:**  
    Users can provide liquidity using an `ERC4626` vault for their strategy and create limit orders that are executed when certain price levels are reached. This can help maintain the liquidity into the strategy until the price of the underleying asset reach certain condition(s) (ex: You could choose to stop lending your `USDC`s if they depeg more than 2% and swap them to `GHO`!).  

***ERC4626 Vault Standard***  
**YielDex** protocol is built on top of the `ERC4626` vault standard, which is specifically designed for yield strategies. This means that users can store their liquidity in a secure and standardized way, and easily withdraw or swap their funds when needed. You currently just have to give an `ERC4626` address into the order parameter in order that your liquidity goes to it while the order is still pending.
### **Futur use cases**

1. **Risk Management**  
**YielDex** protocol enables users to manage their risk exposure. Users can set up strategies that will automatically move their funds between different platforms based on certain risk criteria. For example, a user could set up a strategy to automatically withdraw their funds from a platform if the platform's reward token price deviates more than a certain percentage (it could be any conditions).


2. **Advanced trading startegies**  
With the current features of **YielDex** protocol, users can already create on-chain limit orders that are executed on-chain, while their liquidity is working on the chosen `ERC4626` vault. However, there are some additional advanced trading strategies that can be implemented to enhance the optimization of liquidity, such as:

    - **Order criteria based on another asset:**  
    Users can base their order criteria on another asset, which means that they can create an order to buy an asset at the market price only if the price of another asset meets a certain condition. For example, a user might want to buy `ETH` with their stablecoins but knows that `ETH`'s price is currently dependent on `Bitcoin`'s price. So, they can create an order to buy `ETH` only if the price of `Bitcoin` goes down, which could help them get a better price for `ETH`.  

    - **Multiple order criteria:**
    Users can create multiple order criteria to validate their decision to buy an asset. For example, they might want to buy an asset only if both the price of `Bitcoin` and the price of another stablecoin meet certain conditions. This can help them avoid making a mistake due to a single price fluctuation. We could also add some oracles here if the users need to have special indicators (like `RSI` of an asset).

    - **List of assets to buy:**  
    Users can create a list of assets to buy, and the first asset that meets the condition will be the one that is bought. For example, a user might want to buy `ETH` at $900, but they are also willing to buy `BTC` at $14,000 instead if `ETH`'s price does not meet the condition.  

    - **Opening spot orders on behalf of someone else:**  
    **YielDex** protocol could be very easily extended to allow the opening of spot orders on behalf of someone else. For example, if a user is an on-chain copy trading protocol, other users could send them some liquidity, and they could use it to open orders on their behalf.  

    These advanced trading strategies can help users optimize their liquidity even further and create highly customized strategies for their specific needs. With the **YielDex** protocol's ability to execute on-chain orders, users can take advantage of the security and efficiency of the `ERC4626` vault standard to manage their liquidity.  

3. **Infinite possibilities, for the end-user... and the buidlers!**  
We will provide a variety of smart contract components, or "bricks," that end-users can manage using the front-end interface. Developers can also use these bricks directly by deploying compatible contracts with their own parameters. With `YielDex` protocol, users can choose which protocols to use for liquidity swaps or lending, and can define their own criteria for these actions. The possibilities for customizing your liquidity management strategy are virtually infinite!

### **Conclusion**  

**YielDex** protocol provides users with the ability to create highly customized strategies for liquidity optimization. Whether you are looking to automate liquidity provisioning, optimize yield aggregation, manage your risk exposure, or create your own custom strategy, **YielDex** protocol can help. By leveraging the power of on-chain execution and the `ERC4626` vault standard, we provide users with a secure and efficient way to optimize their liquidity.

### **How to test this project**  
Simple.  
1. First, switch to `Mumbai` (`Polygon` Testnet) get some free testnet native tokens [here](https://faucet.polygon.technology/) and some free AAVE [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s testnet tokens [here](https://app.aave.com/faucet/?marketName=proto_mumbai_v3).
2. Then, fund the [OrderExecutor](https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767) contract if it is not with approximatively 0.05 matic (it should be more than enough). It is needed because [OrderExecutor](https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767) will execute your swap tx.
3. Now, we are gonna create our order. In order to to this, `approve` [OrderBook](https://mumbai.polygonscan.com/address/0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0) contract to take your [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s [here](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234#writeContract). I suggest you to approve `10` [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s (since [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234) token has `6` decimals you should put `10000000`) because otherwise you will f*ck the pool price and it will not be funny for others anymore.
4. Create your order! For this, use `createOrder` function into the [YielDexLiteProxy](https://mumbai.polygonscan.com/address/0xc59d5cAa781868FeA755276fc2609299a9719F37) contract.  
    - You should put an arbitrary price (for the demo you will be able to control the price, which is by default equals to `100`, so don't put that number except if you want that the order to be directly executed).
    - Next, put the `amount` you just approved into the previous step.
    - and finally the addresses of the `tokenIn` ([USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234) address) and the `tokenOut` address (Since the `UniswapV3` liquidity pools are often empty on `Mumbai` testnet I have funded the `USDC/USDT` liquidity pool so I suggest you try with a small amount of [USDT](https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0)s)
5. Your liquidity should work on `AAVEV3` now! Congratulation! Let's get it back and swap it to another asset in the same block now.
    - Just use `setPrice` function of [YielDexLiteProxy](https://mumbai.polygonscan.com/address/0xc59d5cAa781868FeA755276fc2609299a9719F37) contract in order to trigger the price you just set up into your order (put the exact same data).
    - You can now see that you have get back your asset as a `tokenOut` asset.

Note: When you create an order the `createOrder` function will return you a nonce that you can use to check the state of the order as well of the `Gelato` task. You can check it with the `getOrder` function of the [YielDexLiteProxy](https://mumbai.polygonscan.com/address/0xc59d5cAa781868FeA755276fc2609299a9719F37) contract.


### **Mumbai contracts informations**
| Contract name | Contract address | Contract Link |
| --------------- | --------------- | --------------- |
|[YielDexLiteProxy](https://mumbai.polygonscan.com/address/0xc59d5caa781868fea755276fc2609299a9719f37)| 0xc59d5caa781868fea755276fc2609299a9719f37|https://mumbai.polygonscan.com/address/0xc59d5caa781868fea755276fc2609299a9719f37|
|[OrderBook](https://mumbai.polygonscan.com/address/0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0)| 0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0|https://mumbai.polygonscan.com/address/0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0|
|[OrderExecutor](https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767)| 0xa6f9edaeeceefddf1f3e17371d81ceb860d35767|https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767|
|[LendingVault](https://mumbai.polygonscan.com/address/0x0930bae089461ad90996f2c33f1df2e8a520e516)| 0x0930bae089461ad90996f2c33f1df2e8a520e516|https://mumbai.polygonscan.com/address/0x0930bae089461ad90996f2c33f1df2e8a520e516|
|[AAVE USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)| 0xe9DcE89B076BA6107Bb64EF30678efec11939234|https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234|
|[AAVE USDT](https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0)| 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|

### **How to deploy this project** 
1. Install [Foundry](https://github.com/foundry-rs/foundry) (you can get some ressources [here](https://book.getfoundry.sh/)).
2. Copy `example.env` to `.env` file at the root of your project and complete it with your own private keys.
3. Run these three commands:
```
source .env
forge install
forge test -vv
forge script script/Deploy_MUMBAI.s.sol:DeployScript --broadcast --rpc-url ${RPC_URL_MUMBAI} --verifier-url ${VERIFIER_URL_MUMBAI} --etherscan-api-key ${POLYGON_ETHERSCAN_API_KEY} --verify
```