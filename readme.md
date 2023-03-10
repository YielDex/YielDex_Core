### How to test this project  
Simple.  
1. First, switch to `Mumbai` (`Polygon` Testnet) get some free testnet native tokens [here](https://faucet.polygon.technology/) and some free aave [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s testnet tokens [here](https://app.aave.com/faucet/?marketName=proto_mumbai_v3).
2. Then, fund the [OrderExecutor](https://mumbai.polygonscan.com/address/0xc65167BEba5d794Cb55Ab19711262D5bc379F653) contract if it is not with approximatively 0.05 matic (it should be more than enough). It is needed because [OrderExecutor](https://mumbai.polygonscan.com/address/0xc65167BEba5d794Cb55Ab19711262D5bc379F653) will execute your swap tx.
3. Now, we are gonna create our order. In order to to this, `approve` [OrderBook](https://mumbai.polygonscan.com/address/0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3) contract to take your [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s [here](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234#writeContract). I suggest you to approve `10` [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)s (since [USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234) token has `6` decimals you should put `10000000`) because otherwise you will f*ck the pool price and it will not be funny for others anymore.
4. Create your order! For this, use `createOrder` function into the [OrderBook](https://mumbai.polygonscan.com/address/0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3) contract.  
    - You should put an arbitrary price (for the demo you will be able to control the price, which is by default equals to `100`, so don't put that number except if you want that the order to be directly executed).
    - Next, put the `amount` you just approved into the previous step.
    - and finally the addresses of the `tokenIn` ([USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234) address) and the `tokenOut` address (Since the `UniswapV3` liquidity pools are often empty on `Mumbai` testnet I have funded the `USDC/USDT` liquidity pool so I suggest you try with a small amount of [USDT](https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0))
5. Your liquidity should work on `AAVEV3` now! Congratulation! Let's get it back and swap it to another asset in the same block now.
    - Just use `setPrice` function of [OrderExecutor](https://mumbai.polygonscan.com/address/0xc65167BEba5d794Cb55Ab19711262D5bc379F653) contract in order to trigger the price you just set up into your order (put the exact same data).
    - You can now see that you have get back your asset as a `tokenOut` asset.

Note: When you create an order the `createOrder` function will return you a nonce that you can use to check the state of the order as well of the `Gelato` task. You can check it with the `getOrder` function of the [OrderBook](https://mumbai.polygonscan.com/address/0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3) contract.


### Mumbai contracts informations
| Contract name | Contract address | Contract Link |
| --------------- | --------------- | --------------- |
|[OrderBook](https://mumbai.polygonscan.com/address/0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3)| 0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3|https://mumbai.polygonscan.com/address/0x0F1644201713bAD88FC93A2927DBf0B9A6D421f3|
|[OrderExecutor](https://mumbai.polygonscan.com/address/0xc65167BEba5d794Cb55Ab19711262D5bc379F653)  | 0xc65167BEba5d794Cb55Ab19711262D5bc379F653|https://mumbai.polygonscan.com/address/0xc65167BEba5d794Cb55Ab19711262D5bc379F653|
|[LendingVault](https://mumbai.polygonscan.com/address/0xf7cC49bad9Dc13745BCF2de45ED605217Cdb7f72)| 0xf7cC49bad9Dc13745BCF2de45ED605217Cdb7f72|https://mumbai.polygonscan.com/address/0xf7cC49bad9Dc13745BCF2de45ED605217Cdb7f72|
|[AAVE USDC](https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234)| 0xe9DcE89B076BA6107Bb64EF30678efec11939234|https://mumbai.polygonscan.com/token/0xe9DcE89B076BA6107Bb64EF30678efec11939234|
|[AAVE USDT](https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0)| 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|https://mumbai.polygonscan.com/token/0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0|

### How to deploy this project 
1. Install [Foundry](https://github.com/foundry-rs/foundry) (you can get some ressources [here](https://book.getfoundry.sh/)).
2. Copy `example.env` to `.env` file at the root of your project and complete it with your own private keys.
3. Run these two commands:
```
source .env
forge script script/Deploy_MUMBAI.s.sol:DeployScript --broadcast --rpc-url ${RPC_URL_MUMBAI} --verifier-url ${VERIFIER_URL_MUMBAI} --etherscan-api-key ${POLYGON_ETHERSCAN_API_KEY} --verify
```