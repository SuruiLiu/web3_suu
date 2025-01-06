# Merkle Airdrop 实现教程

## 第一部分：基础概念

### 1. 什么是 Merkle Tree
Merkle Tree(默克尔树)是一种树形数据结构,每个非叶子节点都是其子节点内容的哈希值。在区块链中广泛应用于:
- 高效验证大量数据
- 优化存储空间
- 实现轻节点验证

### 2. 为什么使用 Merkle Tree 做空投
使用 Merkle Tree 进行空投有以下优势:
- 节省gas费用：合约只需存储一个root哈希
- 可扩展性：支持大规模空投
- 灵活性：可以按需提供证明

## 第二部分：项目结构

```
foundry-merkle-airdrop/
├── src/
│   ├── BagelToken.sol        # ERC20代币合约
│   └── MerkleAirdrop.sol     # 空投合约
├── script/
│   ├── GenerateInput.s.sol   # 生成空投名单
│   └── MakeMerkle.s.sol      # 生成Merkle树
├── test/
│   └── unit/                 # 单元测试
└── README.md
```

## 第三部分：实现步骤

### 1. 创建代币合约
首先我们需要创建一个ERC20代币合约作为空投的代币:

```solidity
// src/BagelToken.sol
contract BagelToken is ERC20 {
    constructor() ERC20("Bagel", "BAGEL") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}
```

### 2. 创建空投合约
空投合约需要实现以下4个功能:
- 存储Merkle root
- 验证空投资格
- 记录已领取地址
- 发放代币

```solidity
// src/MerkleAirdrop.sol
contract MerkleAirdrop {
    // Merkle树根
    bytes32 public immutable merkleRoot;
    
    // 代币合约
    IERC20 public immutable token;
    
    // 记录已领取地址
    mapping(address => bool) public hasClaimed;
    
    constructor(bytes32 _merkleRoot, address _token) {
        merkleRoot = _merkleRoot;
        token = IERC20(_token);
    }
    
    // 验证并领取空投
    function claim(bytes32[] calldata proof, uint256 amount) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        
        // 验证Merkle证明
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(verify(proof, merkleRoot, leaf), "Invalid proof");
        
        // 标记为已领取
        hasClaimed[msg.sender] = true;
        
        // 发送代币
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }
    
    // 验证Merkle证明
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        
        return computedHash == root;
    }
}
```

### 3. 生成空投名单
创建一个脚本生成空投地址列表:

```solidity
// script/GenerateInput.s.sol
contract GenerateInput is Script {
    function run() public {
        // 空投名单
        address[] memory whitelist = new address[](3);
        whitelist[0] = address(0x1);
        whitelist[1] = address(0x2);
        whitelist[2] = address(0x3);
        
        // 空投数量
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 1e18;
        amounts[1] = 200 * 1e18;
        amounts[2] = 300 * 1e18;
        
        // 生成输入文件
        string memory json = generateJson(whitelist, amounts);
        vm.writeFile("script/input.json", json);
    }
}
```

### 4. 生成Merkle树
基于空投名单生成Merkle树:

```solidity
// script/MakeMerkle.s.sol
contract MakeMerkle is Script {
    function run() public {
        // 读取输入文件
        string memory input = vm.readFile("script/input.json");
        
        // 解析地址和数量
        (address[] memory addresses, uint256[] memory amounts) = parseInput(input);
        
        // 生成叶子节点
        bytes32[] memory leaves = new bytes32[](addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(addresses[i], amounts[i]));
        }
        
        // 构建Merkle树
        bytes32 root = buildMerkleTree(leaves);
        
        // 生成证明
        bytes32[][] memory proofs = generateProofs(leaves);
        
        // 保存结果
        saveOutput(root, proofs);
    }
}
```

## 第四部分：测试

### 1. 单元测试
创建测试用例验证合约功能:

```solidity
// test/unit/MerkleAirdropTest.t.sol
contract MerkleAirdropTest is Test {
    BagelToken public token;
    MerkleAirdrop public airdrop;
    
    function setUp() public {
        // 部署合约
        token = new BagelToken();
        airdrop = new MerkleAirdrop(merkleRoot, address(token));
        
        // 转移代币到空投合约
        token.transfer(address(airdrop), 1000000 * 1e18);
    }
    
    function testClaim() public {
        // 准备测试数据
        address user = address(0x1);
        uint256 amount = 100 * 1e18;
        bytes32[] memory proof = getProof(user);
        
        // 模拟用户
        vm.startPrank(user);
        
        // 验证领取
        airdrop.claim(proof, amount);
        assertEq(token.balanceOf(user), amount);
        assertTrue(airdrop.hasClaimed(user));
        
        vm.stopPrank();
    }
}
```

### 2. 本地测试网络部署
使用Anvil进行本地测试:

```bash
# 启动本地节点
anvil

# 部署合约
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

## 第五部分：实际操作流程

1. 克隆项目
```bash
git clone https://github.com/Cyfrin/foundry-merkle-airdrop-cu
cd foundry-merkle-airdrop-cu
```

2. 安装依赖
```bash
forge install
```

3. 生成空投数据
```bash
forge script script/GenerateInput.s.sol
forge script script/MakeMerkle.s.sol
```

4. 部署合约
```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

5. 验证合约
```bash
forge verify-contract $CONTRACT_ADDRESS src/MerkleAirdrop.sol:MerkleAirdrop
```

## 注意事项

1. 安全考虑
- 确保Merkle树生成正确
- 防止重复领取
- 合约升级机制
- 紧急暂停功能

2. Gas优化
- 批量验证和领取
- 优化数据结构
- 减少存储操作

3. 用户体验
- 提供友好的领取界面
- 显示领取状态
- 错误提示明确

## 总结

通过本教程,我们学习了:
1. Merkle Tree的基本原理和应用
2. 如何实现空投合约
3. 如何生成和验证Merkle证明
4. 如何进行合约测试和部署
5. 项目开发的最佳实践

需要继续深入了解某个部分吗？ 