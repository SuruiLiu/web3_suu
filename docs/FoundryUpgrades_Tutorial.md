# Foundry 智能合约升级教程

## 第一部分：基础概念

### 1. 什么是智能合约升级
智能合约升级是一种允许我们修改已部署合约功能的机制。由于区块链的不可变性，合约一旦部署就无法直接修改，因此需要特殊的升级模式。主要包括：
- 代理模式（Proxy Pattern）
- 透明代理（Transparent Proxy）
- UUPS（Universal Upgradeable Proxy Standard）
- Beacon代理

### 2. 为什么需要合约升级
合约升级的主要原因：
- 修复安全漏洞
- 添加新功能
- 优化性能
- 适应新的业务需求

### 3. 不同代理模式的比较

#### 3.1 透明代理（Transparent Proxy）
- 优点：
  - 清晰的权限分离
  - 避免函数选择器冲突
- 缺点：
  - gas成本较高
  - 部署成本高

#### 3.2 UUPS代理
- 优点：
  - gas成本低
  - 更灵活的升级机制
- 缺点：
  - 实现复杂度高
  - 需要在实现合约中包含升级逻辑

#### 3.3 Beacon代理
- 优点：
  - 支持批量升级
  - 统一管理多个代理
- 缺点：
  - 额外的间接层
  - 部署成本高

## 第二部分：项目结构

```
foundry-upgrades/
├── src/
│   ├── BoxV1.sol           # 初始版本合约
│   ├── BoxV2.sol           # 升级版本合约
│   ├── UUPSProxy.sol       # UUPS代理合约
│   ├── TransparentProxy.sol # 透明代理合约
│   └── BeaconProxy.sol     # Beacon代理合约
├── script/
│   ├── DeployBox.s.sol     # 部署脚本
│   └── UpgradeBox.s.sol    # 升级脚本
├── test/
│   └── unit/               # 单元测试
└── README.md
```

## 第三部分：实现步骤

### 1. 创建初始版本合约（BoxV1）
```solidity
// src/BoxV1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoxV1 is Initializable {
    uint256 private _value;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize() public initializer {
        __Box_init();
    }
    
    function __Box_init() internal onlyInitializing {
        __Box_init_unchained();
    }
    
    function __Box_init_unchained() internal onlyInitializing {
    }
    
    // 存储值
    function store(uint256 value) public {
        _value = value;
    }
    
    // 读取值
    function retrieve() public view returns (uint256) {
        return _value;
    }
    
    // 获取合约版本
    function version() public pure returns (uint256) {
        return 1;
    }
}
```

### 2. 创建升级版本合约（BoxV2）
```solidity
// src/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BoxV1.sol";

contract BoxV2 is BoxV1 {
    // 新增功能：将存储的值翻倍
    function increment() public {
        store(retrieve() * 2);
    }
    
    // 重写版本号
    function version() public pure override returns (uint256) {
        return 2;
    }
}
```

### 3. 实现UUPS代理
```solidity
// src/UUPSProxy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoxUUPS is BoxV1, UUPSUpgradeable, Ownable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize() public initializer {
        __Box_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }
    
    // UUPS必须在实现合约中重写该函数
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
```

### 4. 实现透明代理
```solidity
// src/TransparentProxy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract BoxProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) {}
}
```

### 5. 实现Beacon代理
```solidity
// src/BeaconProxy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract BoxBeacon is UpgradeableBeacon {
    constructor(address implementation_) UpgradeableBeacon(implementation_) {}
}

contract BoxBeaconProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {}
}
```

## 第四部分：测试

### 1. UUPS代理测试
```solidity
// test/BoxTest.t.sol
contract BoxTest is Test {
    BoxUUPS public box;
    address public implementation;
    
    function setUp() public {
        // 部署实现合约
        implementation = address(new BoxV1());
        
        // 部署代理合约
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector);
        box = new BoxUUPS();
        box.initialize();
    }
    
    function testUpgrade() public {
        // 测试V1功能
        box.store(42);
        assertEq(box.retrieve(), 42);
        assertEq(box.version(), 1);
        
        // 部署并升级到V2
        address implementationV2 = address(new BoxV2());
        box.upgradeTo(implementationV2);
        
        // 测试V2功能
        BoxV2(address(box)).increment();
        assertEq(box.retrieve(), 84);
        assertEq(box.version(), 2);
    }
}
```

### 2. 透明代理测试
```solidity
contract TransparentBoxTest is Test {
    BoxProxy public proxy;
    ProxyAdmin public admin;
    address public implementation;
    
    function setUp() public {
        // 部署实现合约
        implementation = address(new BoxV1());
        
        // 部署代理管理合约
        admin = new ProxyAdmin();
        
        // 部署代理合约
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector);
        proxy = new BoxProxy(implementation, address(admin), data);
    }
    
    function testUpgrade() public {
        BoxV1 box = BoxV1(address(proxy));
        
        // 测试V1功能
        box.store(42);
        assertEq(box.retrieve(), 42);
        assertEq(box.version(), 1);
        
        // 部署并升级到V2
        address implementationV2 = address(new BoxV2());
        admin.upgrade(ITransparentUpgradeableProxy(address(proxy)), implementationV2);
        
        BoxV2 boxV2 = BoxV2(address(proxy));
        
        // 测试V2功能
        boxV2.increment();
        assertEq(boxV2.retrieve(), 84);
        assertEq(boxV2.version(), 2);
    }
}
```

### 3. Beacon代理测试
```solidity
contract BeaconBoxTest is Test {
    BoxBeacon public beacon;
    BoxBeaconProxy public proxy;
    address public implementation;
    
    function setUp() public {
        // 部署实现合约
        implementation = address(new BoxV1());
        
        // 部署Beacon合约
        beacon = new BoxBeacon(implementation);
        
        // 部署代理合约
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector);
        proxy = new BoxBeaconProxy(address(beacon), data);
    }
    
    function testUpgrade() public {
        BoxV1 box = BoxV1(address(proxy));
        
        // 测试V1功能
        box.store(42);
        assertEq(box.retrieve(), 42);
        assertEq(box.version(), 1);
        
        // 部署并升级到V2
        address implementationV2 = address(new BoxV2());
        beacon.upgradeTo(implementationV2);
        
        BoxV2 boxV2 = BoxV2(address(proxy));
        
        // 测试V2功能
        boxV2.increment();
        assertEq(boxV2.retrieve(), 84);
        assertEq(boxV2.version(), 2);
    }
}
```

## 第五部分：实际操作流程

1. 克隆项目
```bash
git clone https://github.com/Cyfrin/foundry-upgrades-cu
cd foundry-upgrades-cu
```

2. 安装依赖
```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

3. 编译合约
```bash
forge build
```

4. 运行测试
```bash
forge test
```

5. 部署合约
```bash
# 设置环境变量
export PRIVATE_KEY=your_private_key
export RPC_URL=your_rpc_url

# 部署
forge script script/DeployBox.s.sol --rpc-url $RPC_URL --broadcast
```

6. 验证合约
```bash
forge verify-contract $CONTRACT_ADDRESS src/BoxV1.sol:BoxV1
```

## 注意事项

1. 升级安全性考虑
- 存储布局兼容性
  - 新版本必须保持与旧版本相同的存储布局
  - 只能在末尾添加新的存储变量
- 初始化函数
  - 使用initialize代替constructor
  - 确保只能初始化一次
- 访问控制
  - 实现适当的权限控制
  - 多签管理升级权限

2. 最佳实践
- 使用OpenZeppelin的升级插件
- 在升级前进行全面测试
- 实现紧急暂停功能
- 保持合约逻辑简单清晰

3. 存储管理
- 使用固定长度数组
- 避免动态数组大小变化
- 使用映射代替数组
- 注意结构体的扩展性

## 总结

通过本教程，我们学习了：
1. 智能合约升级的基本概念
2. 三种主要的代理模式实现
3. 如何编写和测试可升级合约
4. 实际部署和升级流程
5. 安全性和最佳实践

需要深入了解某个部分吗？ 