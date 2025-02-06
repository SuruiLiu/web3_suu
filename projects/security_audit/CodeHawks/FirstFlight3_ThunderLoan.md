repo:https://github.com/Cyfrin/2023-11-Thunder-Loan

首先看框架范围：
├── interfaces 一般interface不会有什么大问题，扫一眼
│   ├── IFlashLoanReceiver.sol
│   ├── IPoolFactory.sol
│   ├── ITSwapPool.sol
│   #── IThunderLoan.sol
├── protocol 核心audit部分
│   ├── AssetToken.sol
│   ├── OracleUpgradeable.sol
│   #── ThunderLoan.sol
#── upgradedProtocol
    #── ThunderLoanUpgraded.sol

看功能（用自己的话理解）：
1. 给用户闪电贷，在一个交易里借钱还钱再收一点手续费
2. 给流动性提供者赚钱，流动性提供者deposit得到assetToken，这个随着使用闪电贷的次数获得利息
3. 然后后续还要升级，从现在的合约到另一个

AssetToken：
ERC20，加了个underlying的ERC20的token
transferUnderlyingTo(address to, uint256 amount)
updateExchangeRate(uint256 fee)更新token汇率的，newExchangeRate = oldExchangeRate * (totalSupply + fee) / totalSupply
汇率有啥用？

ThunderLoan：
deposit(IERC20 token, uint256 amount)先是计算能换多少assetToken并mint，然后getCalculatedFee来更新汇率，最后把用户的钱转过来
redeem(IERC20 token,uint256 amountOfAssetToken)根据当前的汇率来赎回基础underlyingtoken，先burn了AssetToken，再转underlyingToken
中间的判断为什么一定要==，还有个就是用当前汇率不太对吧签名刚更新也就是一抵押就赎回那不是赚了
flashloan(address receiverAddress, IERC20 token, uint256 amount, bytes calldata params)先算了一下当前这个token的余额，然后getCalculatedFee来更新汇率，然后闪电贷正在进行标志true，然后借出，执行操作，然后计算还回来之后的余额，false
这个fee好像很关键，因为还回来的钱要>=fee+初始余额
repay(IERC20 token, uint256 amount)用户归还闪电贷的代币
怎么理解这个AssetToken，好像就是封装了一层的代币，但是这个代币又只能被这个金融产品使用
setAllowedToken(IERC20 token, bool allowed)设置是否允许某种代币参与闪电贷，如果允许代币且未设置过，则创建对应的资产代币并存储映射关系
记录事件，如果不允许则删除代币映射。
感觉又onlyowner的基本不会有问题，因为不会有owner自己去搞破坏
getCalculatedFee(IERC20 token, uint256 amount)计算闪电贷的手续费，也就是先算了总借出的价值，然后×闪电贷的费率0.3%，返回fee
这个就是slither扫出来的vulnerability，说要你先乘完再除divide-before-multiply

ThunderLoanUpgraded：
基本和ThunderLoan差不多，在deposit中把更新汇率删了
state variables存储的和ThunderLoan不一致，会导致存储问题

补充一下升级合约的：

vulnerabilities：
H:
1. deposit中改汇率，会导致如果一改就redeem的话，可以反复套利了 Valid
2. deposit最后transfer不检查的？Invalid
3. deposit重入攻击 Invalid
4. flashloan中的计算balance方法是uint256 endingBalance = token.balanceOf(address(assetToken));
那么，我只要满足token的balance增加不就行了，不一定用repay来增加，因为deposit好像也能行 Valid
5. 升级时存储冲突，state variables换了个位置就会导致s_flashLoanFee不再正确 Valic
6. 非标准ERC20的代币会导致价格计算不一样，也就是说getCalculatedFee默认传进来的token的decimal是18这是不对的
```solidity
function getCalculatedFee(IERC20 token, uint256 amount) public view returns (uint256 fee) {
        
        //1 ETH = 1e18 WEI
        //2000 USDT = 2 * 1e9 WEI

        uint256 valueOfBorrowedToken = (amount * getPriceInWeth(address(token))) / s_feePrecision;

        // valueOfBorrowedToken ETH = 1e18 * 1e18 / 1e18 WEI
        // valueOfBorrowedToken USDT= 2 * 1e9 * 1e18 / 1e18 WEI

        fee = (valueOfBorrowedToken * s_flashLoanFee) / s_feePrecision;

        //fee ETH = 1e18 * 3e15 / 1e18 = 3e15 WEI = 0,003 ETH
        //fee USDT: 2 * 1e9 * 3e15 / 1e18 = 6e6 WEI = 0,000000000006 ETH
    }
```
M：
1. 先乘再除
2. 如果有个token质押了，但是被setAllowedToken的时候删除了映射，那这个代币就被锁在里面了
3. token.safeTransferFrom(msg.sender, address(assetToken), amount);有些代币会在这个执行中收取手续费，但是mintAssetToken却按照amount，那就会mint多了，导致取出的时候取不够或者把别人的取了导致别人取不够
L：
1. getCalculatedFee中任何amount不超过333都会导致计算出来的fee=0，暂时不知道为啥
2. updateFlashLoanFee 缺少event
3. getCalculatedFee计算可能导致精度丢失，还是得研究一下这个方法getPriceInWeth(address(token)在OracleUpgradeable里


补充一下Initializable, OwnableUpgradeable, UUPSUpgradeable, OracleUpgradeable相关的升级：
Initializable 是 OpenZeppelin 提供的基础合约，用于防止初始化函数被多次调用。由于升级合约没有构造函数（因为代理合约通过 delegatecall 调用逻辑合约），需要使用初始化函数进行设置。
- modifier initializer()确保初始化函数只能调用一次
- _disableInitializers()禁用初始化函数以避免重复初始化。
OwnableUpgradeable 是 OpenZeppelin 提供的权限管理模块，通过所有权控制合约的关键操作。限制某些操作只能由所有者执行，例如升级合约。允许安全转移合约所有权。
UUPSUpgradeable (Universal Upgradeable Proxy Standard) 是一种升级代理模式，使得合约本身能够控制升级逻辑。通过 UUPSUpgradeable 模式，避免存储冲突，简化升级流程，同时确保只有授权地址（通常是所有者）能执行升级。
- function _authorizeUpgrade(address newImplementation) internal virtual;必须由子合约实现，用于授权升级逻辑。
- function upgradeTo(address newImplementation)升级到新的实现合约地址：
``` solidity
function upgradeTo(address newImplementation) external virtual onlyProxy {
    _authorizeUpgrade(newImplementation);
    _upgradeToAndCallUUPS(newImplementation, bytes(""), false);
}
```
OracleUpgradeable该合约假设提供预言机功能，通常用于获取外部数据（如价格、链上数据等），支持升级机制。

第一版ThunderLoan合约要升级到第二版ThunberLoanUpgraded，怎么操作呢，也就是部署了第一版的ThunderLoan之后应该是，部署第二版ThunberLoanUpgraded合约，然后调用第一版的upgradeTo()传入第二版的部署address。那升级之后怎么就变成了，调用同样的方法使用的是第二版升级后的合约的方法呢，难道是所有的方法请求执行都是在proxy合约中调用proxy中保存的最新的ThunderLoan地址加delegatecall来请求方法执行？
这是因为代理合约利用了 delegatecall 来处理请求。
delegatecall 的作用是在代理合约的上下文中执行逻辑合约的方法
逻辑合约的方法会读取、写入 代理合约的存储。msg.sender 和 msg.value 等上下文信息仍然保持用户调用时的状态。
请求流程：
用户通过代理合约调用方法，例如 borrow()。
代理合约拦截请求，通过 delegatecall 转发到逻辑合约地址（存储在 implementation 变量中）。
执行时实际使用的逻辑合约地址就是最新的 ThunderLoanUpgraded。
关于不同升级的模式比较具体看UpgradeablePatterns_Tutorial