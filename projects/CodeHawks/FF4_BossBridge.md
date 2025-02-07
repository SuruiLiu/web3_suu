repo:https://github.com/Cyfrin/2023-11-Boss-Bridge/

首先看框架范围：
./src/
#-- L1BossBridge.sol
#-- L1Token.sol
#-- L1Vault.sol
#-- TokenFactory.sol

Chain(s) to deploy contracts to:
Ethereum Mainnet:
L1BossBridge.sol
L1Token.sol
L1Vault.sol
TokenFactory.sol
ZKSync Era:
TokenFactory.sol
Tokens:
L1Token.sol (And copies, with different names & initial supplies)
这个还有点看不懂有啥用

Role：
Bridge Owner桥主人: A centralized中心化 bridge owner who can:
pause/unpause the bridge in the event of an emergency
set Signers (see below)设置Signer
Signer: Users who can "send" a token from L2 -> L1. 能从L2转token到L1
Vault: The contract owned by the bridge that holds the tokens.
Users: Users mainly only call depositTokensToL2, when they want to send tokens from L1 -> L2.

看功能：
首先是项目是一个桥，把L1的ERC20转移到L2上，L2的部分不包括
用户质押ERC20到L1的Vault里，然后发出event，链下接收到之后到L2上mint出来
三个保险机制 1.owner能够停止运行在紧急下 2.ERC20严格限制种类 3.提取操作需要被桥操作员同意才行
我们只用管发起提取操作的用户是否在L1上存钱了


L1Tokens：
叫BBT，标准ERC20

L1Vault：
桥是owner，只负责`允许`桥转进或转出token
function approveTo(address target, uint256 amount)允许转移

TokenFactory:
用来创建新ERC20的，deploy在L1和L2上

L1BossBridge：
uint256 public DEPOSIT_LIMIT = 100_000 ether;加个constant省gas？
vault.approveTo(address(this), type(uint256).max);在constructor里，允许转这么大嘛？


vulnerabilities：
H:
1. Denial of service在depositTokensToL2中，
if (token.balanceOf(address(vault)) + amount > DEPOSIT_LIMIT) {
            revert L1BossBridge__DepositLimitReached();
        }这个只要balance达到了那就永远无法deposit了
2. withdrawTokensToL1因为没有加防护措施，能够使用同一签名多次提取repay
3. Deploy token contract cannot work in zksync原因是zkSync Era的编译器需要提前知道已部署合约的字节码，因为它在内部完成ContractDeployer系统合约的calldata参数。上面显示的create函数将不能正确工作，因为字节码事先不知道，这会导致合约部署的潜在故障。
4. depositTokensToL2这里会有抢跑发生，就是监听如果有userapprove了token的deposit，他就提前发起depositTokensToL2把L2的接收地址改成他的
5. `sendToL1 `函数应该是`internal`或`private`，以确保签名的消息是所需的，包含`transferfrom`指令。确实是，如果伪造一个signer的sendToL1调用，因为使用了低级call，很有可能会导致owner都被改了
6. 攻击者可以通过将任意数量的相应令牌存入L2来耗尽保险库令牌,因为压根就没有检验存了多少，取的是不是合适的
7. 这个TokenFactory压根没用
L：
1.千奇百怪，还是missing event定式了