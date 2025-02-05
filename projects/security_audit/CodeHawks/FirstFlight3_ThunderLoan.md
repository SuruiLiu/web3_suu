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


vulnerabilities：
H:
1. deposit中改汇率，会导致如果一改就redeem的话，可以反复套利了 Valid
2. deposit最后transfer不检查的？Invalid
3. deposit重入攻击 Invalid
4. flashloan中的计算balance方法是uint256 endingBalance = token.balanceOf(address(assetToken));
那么，我只要满足token的balance增加不就行了，不一定用repay来增加，因为deposit好像也能行 Valid
M：
1. 先乘再除
2. 如果有个token质押了，但是被setAllowedToken的时候删除了映射，那这个代币就被锁在里面了
3. token.safeTransferFrom(msg.sender, address(assetToken), amount);有些代币会在这个执行中收取手续费，但是mintAssetToken却按照amount，那就会mint多了，导致取出的时候取不够或者把别人的取了导致别人取不够
L：
1. getCalculatedFee中任何amount不超过333都会导致计算出来的fee=0，暂时不知道为啥
2. updateFlashLoanFee 缺少event
3. getCalculatedFee计算可能导致精度丢失，还是得研究一下这个方法getPriceInWeth(address(token)在OracleUpgradeable里

