# EVM Signatures 和 Selectors 详解

## 1. 基本概念

### Function Signature（函数签名）
- 函数签名是函数名和参数类型的组合
- 格式：`functionName(parameterType1,parameterType2,...)`
- 例如：`transfer(address,uint256)`

### Function Selector（函数选择器）
- 函数选择器是函数签名的 Keccak-256 哈希的前 4 个字节
- 用于在智能合约调用时识别要执行的函数
- 计算方式：`bytes4(keccak256(bytes("function_signature")))`

## 2. 示例代码

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SignatureExample {
    // 1. 获取函数选择器的几种方法
    function getSelector() public pure returns (bytes4) {
        // 方法1：直接从函数签名字符串计算
        bytes4 selector1 = bytes4(keccak256(bytes("transfer(address,uint256)")));
        
        // 方法2：使用接口方法
        bytes4 selector2 = IERC20.transfer.selector;
        
        return selector1; // 0xa9059cbb
    }

    // 2. 在调用中使用选择器
    function callFunctionWithSelector(address target) public {
        // 编码调用数据
        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256(bytes("transfer(address,uint256)"))),
            address(this),
            100
        );
        
        // 使用低级调用
        (bool success,) = target.call(data);
        require(success, "Call failed");
    }
}
```

## 3. 工作原理

1. **调用过程**：
   ```
   合约调用 -> 函数签名 -> 计算选择器 -> 匹配合约函数 -> 执行函数
   ```

2. **选择器计算示例**：
   ```solidity
   "transfer(address,uint256)" ->
   keccak256 hash ->
   0xa9059cbb2ab09eb219583f4a59a5d0623ade346d962bcd4e46b11da047c9049b ->
   取前4字节 ->
   0xa9059cbb
   ```

## 4. 实际应用

### 代理合约
```solidity
contract Proxy {
    address public implementation;

    function _delegate(address _implementation) internal {
        assembly {
            // 复制msg.data
            calldatacopy(0, 0, calldatasize())
            
            // 调用实现合约
            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )
            
            // 复制返回数据
            returndatacopy(0, 0, returndatasize())
            
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
```

### 接口定义
```solidity
interface IERC20 {
    // 函数签名：transfer(address,uint256)
    // 选择器：0xa9059cbb
    function transfer(address to, uint256 amount) external returns (bool);
}
```

## 5. 常见用途

1. **合约交互**：
   - 使用低级调用（call）时需要函数选择器
   - 实现代理模式时用于函数转发

2. **接口识别**：
   - ERC标准接口识别
   - 函数重载区分

3. **安全性**：
   - 函数选择器碰撞检查
   - 权限控制

## 6. 最佳实践

1. **选择器存储**：
   ```solidity
   // 常量方式存储常用选择器
   bytes4 private constant TRANSFER_SELECTOR = bytes4(
       keccak256(bytes("transfer(address,uint256)"))
   );
   ```

2. **接口使用**：
   ```solidity
   // 优先使用接口定义的选择器
   bytes4 selector = IERC20.transfer.selector;
   ```

3. **选择器验证**：
   ```solidity
   // 验证调用的函数选择器
   require(
       msg.sig == IERC20.transfer.selector,
       "Invalid function selector"
   );
   ```

## 注意事项

1. 函数签名不包含返回类型
2. 参数类型之间不能有空格
3. 选择器碰撞的可能性（虽然极低）
4. 在代理模式中正确处理函数选择器

---

这就是 EVM Signatures 和 Selectors 的核心内容。需要我详细解释某个部分吗？ 