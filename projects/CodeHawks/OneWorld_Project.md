repo:https://github.com/Cyfrin/2024-11-one-world?tab=readme-ov-file

框架：
├── OWPIdentity.sol
├── dao
│   ├── CurrencyManager.sol
│   ├── MembershipFactory.sol
│   ├── interfaces
│   │   ├── ICurrencyManager.sol
│   │   └── IERC1155Mintable.sol
│   ├── libraries
│   │   └── MembershipDAOStructs.sol
│   └── tokens
│       └── MembershipERC1155.sol
└── meta-transaction
      ├── EIP712Base.sol
      └── NativeMetaTransaction.sol

功能：
核心functions：
MembershipFactory：
Create New DAO Membership: 为 DAO 会员部署新的代理合约。
Update DAO Membership: 更新特定 DAO 的会员等级配置。
Join DAO: 允许用户通过购买特定等级的会员 NFT 来加入 DAO。
Upgrade Tier: 允许用户在赞助的 DAO 中升级他们的会员等级。
Set Currency Manager: 更新货币管理器合约。
Call External Contract: 允许工厂合约调用其他外部合约。

MembershipERC1155：
Initialize: 使用名称、符号、URI 和创建者地址初始化合约。
Mint Tokens: 铸造新代币。
Burn Tokens: 销毁现有代币。
Claim Profit: 允许用户从利润池中领取收益。
Send Profit: 向代币持有者分配利润。
Call External Contract: 允许合约调用其他外部合约。