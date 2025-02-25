repo:https://github.com/CodeHawks-Contests/2025-02-gamma

框架：
contract/
├── PerpetualVault.sol
├── GmxProxy.sol
├── KeeperProxy.sol
├── VaultReader.sol
├── interfaces
│   ├── IGmxProxy.sol
│   ├── IPerpetualVault.sol
│   └── IVaultReader.sol
└── libraries
    ├── gmx/
        └──MarketUtils.sol
    ├── Errors.sol
    ├── Order.sol
    ├── ParaSwapUtils.sol
    ├── Position.sol
    └── StructData.sol
    
核心文件：

功能：
存取款：用户存入 USDC，然后提取 USDC。
杠杆交易：协议利用 GMX 永续合约（perps）进行杠杆多头/空头交易。
独立市场：每个 Vault 代表特定市场的固定杠杆倍数，例如 1x ETH、2x ETH、3x ETH Vault。
自动化管理：使用 Keeper 系统异步执行交易操作。
信号驱动：开多、平仓、开空等策略由**链下（off-chain）**信号决定，并由 Keeper 执行。

角色介绍：
1. Owner（合约管理员）
设置协议关键参数（如 Keeper 地址、最小/最大存款金额、锁定时间、回调 Gas 限制）。
暂停存款、更新合约地址、在紧急情况下控制 Vault 状态。
控制 GMX 代理（GmxProxy），调整合约交互、设置最小 ETH 要求、提款 ETH。
管理 KeeperProxy（价格预言机地址、阈值、时间窗口、Keeper 地址）。

2. Keeper（交易执行者）
执行交易操作：开仓 (run())、平仓 (runNextAction())、取消订单 (cancelOrder())。
索赔资金回扣、维护仓位健康度。
受 onlyKeeper 修饰符限制，必须符合 Keeper 资格。

3. 用户（存款者）
存入 USDC 到 Vault
申请提款（但需满足锁定期）
承担 Gas 费用

4. Treasury（治理资金库）
收取治理费用（用户盈利提款时）。
领取资金回扣及协议费用。

工作流程：




PerpetualVault.sol：

