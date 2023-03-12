## Introduction

Welcome to YielDex protocol! This project enables users to create on-chain EVM strategies for liquidity optimization. By constructing their own complex strategies with specific parameters, users can autonomously execute on-chain orders while optimizing their liquidity in ERC4626 vaults.

### Use Cases

1. Automate Liquidity Provisioning
One of the main use cases for our protocol is to automate liquidity provisioning. Users can create custom strategies that will automatically execute trades and move funds between different platforms to optimize their liquidity. For example, a user could set up a strategy to automatically lend their assets on Aave when the yield exceeds a certain threshold, and then withdraw their funds and deposit them into a yield farming pool on a different platform when the yield drops below a certain threshold.

2. Optimize Yield Aggregation
Another key use case for our protocol is to optimize yield aggregation. Users can set up strategies that will automatically move their funds between different platforms to maximize their yield. For example, a user could set up a strategy that aggregates liquidity across multiple platforms, such as Aave, Compound, and Curve, and automatically moves their funds to the platform with the highest yield.

3. Risk Management
Our protocol also enables users to manage their risk exposure. Users can set up strategies that will automatically move their funds between different platforms based on certain risk criteria. For example, a user could set up a strategy to automatically withdraw their funds from a platform if the platform's asset price deviates more than a certain percentage from the peg.
(You could choose to stop lending your USTs/USDCs if they depeg more than 2% and swap them to GHO!)

5. ERC4626 Vault Standard
Our protocol is built on top of the ERC4626 vault standard, which is specifically designed for yield strategies. This means that users can store their liquidity in a secure and standardized way, and easily withdraw or swap their funds when needed. You currently just have to give an ERC4626 address into the order parameter in order that your liquidity goes to it while the order is still pending.

6. Infinite possibilities, for the end-user... and the buidlers!
We will provide a variety of smart contract components, or "bricks," that end-users can manage using our front-end interface. Developers can also use these bricks directly by deploying compatible contracts with their own parameters. With our protocol, users can choose which protocols to use for liquidity swaps or lending, and can define their own criteria for these actions. The possibilities for customizing your liquidity management strategy are virtually infinite!

### Conclusion

YielDex protocol provides users with the ability to create highly customized strategies for liquidity optimization. Whether you are looking to automate liquidity provisioning, optimize yield aggregation, manage your risk exposure, or create your own custom strategy, our protocol can help. By leveraging the power of on-chain execution and the ERC4626 vault standard, we provide users with a secure and efficient way to optimize their liquidity.

### How to test this project  
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


### Mumbai contracts informations
| Contract name | Contract address | Contract Link |
| --------------- | --------------- | --------------- |
|[YielDexLiteProxy](https://mumbai.polygonscan.com/address/0xc59d5caa781868fea755276fc2609299a9719f37)| 0xc59d5caa781868fea755276fc2609299a9719f37|https://mumbai.polygonscan.com/address/0xc59d5caa781868fea755276fc2609299a9719f37|
|[OrderBook](https://mumbai.polygonscan.com/address/0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0)| 0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0|https://mumbai.polygonscan.com/address/0xad9d3c6fe0087b2b8b7e16918a8750be2b9178e0|
|[OrderExecutor](https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767)| 0xa6f9edaeeceefddf1f3e17371d81ceb860d35767|https://mumbai.polygonscan.com/address/0xa6f9edaeeceefddf1f3e17371d81ceb860d35767|
|[LendingVault](https://mumbai.polygonscan.com/address/0x0930bae089461ad90996f2c33f1df2e8a520e516)| 0x0930bae089461ad90996f2c33f1df2e8a520e516|https://mumbai.polygonscan.com/address/0x0930bae089461ad90996f2c33f1df2e8a520e516|
|[AAVE USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)| 0xe9DcE89B076BA6107Bb64EF30678efec11939234|https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234|
|[AAVE USDT](https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0)| 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|

### How to deploy this project 
1. Install [Foundry](https://github.com/foundry-rs/foundry) (you can get some ressources [here](https://book.getfoundry.sh/)).
2. Copy `example.env` to `.env` file at the root of your project and complete it with your own private keys.
3. Run these three commands:
```
source .env
forge install
forge test -vv
forge script script/Deploy_MUMBAI.s.sol:DeployScript --broadcast --rpc-url ${RPC_URL_MUMBAI} --verifier-url ${VERIFIER_URL_MUMBAI} --etherscan-api-key ${POLYGON_ETHERSCAN_API_KEY} --verify
```