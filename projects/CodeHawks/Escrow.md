repo:https://github.com/Cyfrin/2023-07-escrow

框架：
src/
├── Escrow.sol
├── EscrowFactory.sol
├── IEscrow.sol
├── IEscrowFactory.sol

功能：
让auditor和需要审计的项目方有个连接，然后有可选的仲裁

角色介绍：
买方 (Buyer): 服务的购买者，在此场景中指购买审计服务的项目方。
卖方 (Seller): 服务的提供者，在此场景中指愿意为项目提供审计的审计人员。
仲裁方 (Arbiter): 公正可信的角色，负责在买卖双方之间处理争议。

设计考虑：
- 仲裁费 (Arbiter Fee)仲裁方只有在发生争议时才会获得仲裁费用。
- 争议不可取消，一旦争议被发起，就无法取消。
- ERC777 代币限制，不应使用 ERC777 作为支付代币，因为这可能会导致恶意买方利用 DoS 攻击阻止 Escrow::resolveDispute 的执行。
- 防范前跑攻击，如果一个智能合约调用 EscrowFactory::newEscrow，由于调用者可以控制 salt 值，可能存在前跑攻击的风险。

工作流程：
创建 Escrow
买方授权 EscrowFactory 合约处理支付资金。
买方调用 EscrowFactory::newEscrow 方法，输入以下参数：
价格 (price)
支付代币 (payment token)
卖方 (seller)：即审计员或审计负责人
仲裁方 (arbiter)
仲裁费用 (arbiter fee)：发生争议时支付给仲裁方的费用
盐值 (salt)：用于通过 create2 部署 Escrow 合约
预期成功工作流
买方通过 EscrowFactory::newEscrow 创建 Escrow 合约并存入资金。
卖方向买方提供审计报告（线下传递）。
买方通过调用 Escrow::confirmReceipt 确认收到报告，将资金发送给卖方。
预期争议工作流
买方通过 EscrowFactory::newEscrow 创建 Escrow 合约并存入资金。
无论出于何种原因，买方或卖方都可以通过调用 Escrow::initiateDispute 发起争议。
仲裁方与双方进行线下沟通，并通过调用 Escrow::resolveDispute 对争议进行处理，根据情况将资金退还给买方或卖方，同时清空 Escrow。

补充说明create2：

很简单的几个功能functions就不细写了

Vulnerabilities：
M：
1. 因为有些代币如WETH会在safetransfer中扣一部分的手续费，所以再判断的时候if (tokenContract.balanceOf(address(this)) < price) revert Escrow__MustDeployWithTokenBalance();就会revert，那也就会创建不了，不太明白这为什么只是M的bug
2. 如果没有设置arbiter，买家永远无法收回发送到托管的资金，导致代币永远丢失。因为没有办法初始化dispute，就只能白给auditor
3. USDC 等带有黑名单机制的代币。USDC 等知名代币具有一项功能：如果用户地址被黑名单限制（黑名单地址无法接收或发送代币），就会导致与该地址相关的交易完全失败。如果任一接收地址（buyer、seller 或 arbiter）被 USDC 黑名单限制：任何转账操作都会 revert，导致函数无法执行。合约永久锁定资金，所有参与方都无法再取回款项。
4. 使用具有动态余额（Rebasing）的代币。Rebasing 代币的余额会随时间自动调整（增加或减少），但用户的代币持有数量表面上不变。这可能导致在支付 i_arbiterFee（仲裁费）时出现问题。因为仲裁费固定就意味着可能支付的不是想支付的价值
L:
1. buyer，seller，arbiter应该检查不是同一个人（实际上没人这么干，因为纯亏）
2. 如果没有arbiter，那么arbiterfee就应该是0，但是实际没有这么检验甚至是固定fee
3. resolve里的event不合适，resolveDispute函数不包括Resolved事件中的所有相关信息。该事件发出买方和卖方地址。但是，它不包括任何其他信息，例如买方裁决、仲裁费用或支付给买方的金额。