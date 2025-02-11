reop:https://github.com/Cyfrin/2025-02-raac

框架：
contracts
├── core
│   ├── collectors
│   │   ├── FeeCollector.sol
│   │   └── Treasury.sol
│   ├── governance
│   │   ├── boost
│   │   │   └── BoostController.sol
│   │   ├── gauges
│   │   │   ├── BaseGauge.sol
│   │   │   ├── GaugeController.sol
│   │   │   ├── RAACGauge.sol
│   │   │   └── RWAGauge.sol
│   │   └── proposals
│   │       ├── Governance.sol
│   │       └── TimelockController.sol
│   ├── minters
│   │   ├── RAACMinter
│   │   │   └── RAACMinter.sol
│   │   └── RAACReleaseOrchestrator
│   │       └── RAACReleaseOrchestrator.sol
│   ├── oracles
│   │   ├── RAACHousePriceOracle.sol
│   │   └── RAACPrimeRateOracle.sol
│   ├── pools
│   │   ├── LendingPool
│   │   │   └── LendingPool.sol
│   │   └── StabilityPool
│   │       └── StabilityPool.sol
│   ├── primitives
│   │   └── RAACHousePrices.sol
│   └── tokens
│       ├── DEToken.sol
│       ├── DebtToken.sol
│       ├── RAACNFT.sol
│       ├── RAACToken.sol
│       ├── RToken.sol
│       └── veRAACToken.sol
├── libraries
│   ├── math
│   │   ├── TimeWeightedAverage.sol
│   └── pools
│       └── ReserveLibrary.sol
└── zeno
    ├── Auction.sol
    ├── ZENO.sol


Role：
NFT Owner: 拥有可在借贷池中使用的 RAAC NFT。可能因持有此 NFT 而获得代币。
Lender: 拥有 crvUSD 并将其存入借贷池或稳定池。借出时获得 RToken。贷方可以在 StabilityPool 中存入 RToken 并获得 deToken（债务代币）。
Borrower: 将其 NFT 作为抵押品并借入 CRVUSD 的 NFT 持有者。
Minter: 在借款增加时，债务以 DebtToken 表示。
Collector: 接收交换税费和类似收入的合约（FeeCollector）。
Proposer: 拥有 veRAAC，能够提出新的治理提案。
Delegator: 拥有 veRAAC，但将权力委托给另一个地址。
Executer: 能够执行已计划治理提案的合约或用户。
Oracle: 在 RAACHousePrice 中更改房屋价格并在 LendingPool 中更新基准利率。
Manager: 在池中拥有特定资金访问权限（稳定池）。
Minter: 由稳定池交互触发执行，负责向稳定池铸造新的 RAAC 代币以供后续分配。
Deployer: 部署初始智能合约并是 Ownable 智能合约的所有者的参与者。
Seller: RAAC NFT 的卖家。一个实体公司或个人。