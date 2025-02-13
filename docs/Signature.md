这个教程主要讲解了**Ethereum 签名标准**——**EIP 191 和 EIP 712**，并介绍了如何进行签名和验证。

## **背景**
在这些标准出现之前，使用 **MetaMask** 等钱包签署交易时，通常会得到难以阅读的消息，使得验证交易数据变得困难。此外，传统的签名方式容易遭受**重放攻击（Replay Attack）**，即恶意用户可以重复使用相同的签名进行欺诈交易。

**EIP 191 和 EIP 712** 的主要作用：
1. **提高数据可读性**，使签名数据更加直观。
2. **防止重放攻击**，确保签名数据只能用于特定的交易环境。

---

## **基础签名验证**
在以太坊上，`ecrecover` 是一个内置函数，用于从签名中**恢复签名者的地址**。

### **示例 1：简单签名验证**
```solidity
function getSignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
    bytes32 hashedMessage = bytes32(message);
    address signer = ecrecover(hashedMessage, _v, _r, _s);
    return signer;
}
```
**工作原理**：
1. 计算 `message` 的哈希值 `hashedMessage`。
2. 使用 `ecrecover` 方法恢复出签名者的 `address`。

**示例 2：验证签名**
```solidity
function verifySignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer) public pure returns (bool) {
    address actualSigner = getSignerSimple(message, _v, _r, _s);
    require(signer == actualSigner);
    return true;
}
```
**作用**：
- 检查恢复出的 `actualSigner` 是否与传入的 `signer` 匹配，确保签名有效。

---

## **EIP 191：标准化签名格式**
**EIP 191** 规定了一种标准格式，使签名可读性更高，同时支持**代付（Sponsored Transactions）**。

### **数据格式**
```plaintext
0x19 <1-byte 版本> <版本特定数据> <待签名数据>
```
- **0x19**：前缀，标识数据为签名数据。
- **1-byte 版本**：
  - **0x00**：有指定验证人的数据。
  - **0x01**：结构化数据（常用于 **EIP 712**）。
  - **0x45**：个人签名消息（Personal Sign）。
- **版本特定数据**：
  - 对于 **0x01**，是验证者（智能合约）的地址。
- **待签名数据**：用户实际要签名的消息。

### **EIP 191 签名验证**
```solidity
function getSigner191(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
    bytes1 prefix = bytes1(0x19);
    bytes1 eip191Version = bytes1(0);
    address intendedValidatorAddress = address(this);
    bytes32 applicationSpecificData = bytes32(message);

    bytes32 hashedMessage = keccak256(abi.encodePacked(prefix, eip191Version, intendedValidatorAddress, applicationSpecificData));
    address signer = ecrecover(hashedMessage, _v, _r, _s);
    return signer;
}
```
**工作原理**：
1. 按照 **EIP 191** 规范对消息进行编码。
2. 使用 `keccak256` 计算哈希值。
3. 通过 `ecrecover` 获取签名者的 `address`。

---

## **EIP 712：结构化数据签名**
**EIP 712** 是 **EIP 191** 的扩展，允许对结构化数据进行签名，提高可读性并防止跨合约重放攻击。

### **数据格式**
```plaintext
0x19 0x01 <domainSeparator> <hashStruct(message)>
```
- **0x19 0x01**：EIP 712 特有的前缀。
- **domainSeparator**：领域分隔符，确保数据在特定合约和链 ID 下有效。
- **hashStruct(message)**：结构化数据的哈希值。

### **定义领域分隔符**
```solidity
struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
};

bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
```
**作用**：
- 领域分隔符 `domainSeparator` 用于区分不同的智能合约，防止重放攻击。

### **计算领域分隔符**
```solidity
bytes32 domainSeparator = keccak256(
  abi.encode(
    EIP712DOMAIN_TYPEHASH,
    keccak256(bytes(eip712Domain.name)),
    keccak256(bytes(eip712Domain.version)),
    eip712Domain.chainId,
    eip712Domain.verifyingContract
  )
);
```

### **定义消息结构**
```solidity
struct Message {
    uint256 number;
};

bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 number)");
```
**作用**：
- 预定义消息类型，确保所有签名数据格式一致。

### **计算哈希值**
```solidity
bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ number: message })));
```

### **EIP 712 签名验证**
```solidity
contract SignatureVerifier {
    function getSignerEIP712(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
        bytes1 prefix = bytes1(0x19);
        bytes1 eip712Version = bytes1(0x01);
        bytes32 hashStructOfDomainSeparator = domainSeparator;

        bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ number: message })));
        bytes32 digest = keccak256(abi.encodePacked(prefix, eip712Version, hashStructOfDomainSeparator, hashedMessage));

        return ecrecover(digest, _v, _r, _s);
    }
}
```
**作用**：
1. 组合 `domainSeparator` 和 `message` 哈希值。
2. 计算 `digest` 作为最终签名数据。
3. 使用 `ecrecover` 获取签名者地址。

---

## **使用 OpenZeppelin 简化 EIP 712**
**OpenZeppelin** 提供了 `EIP712::_hashTypedDataV4` 进行哈希计算。

### **获取消息哈希**
```solidity
bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 message)");

function getMessageHash(uint256 _message) public view returns (bytes32) {
    return _hashTypedDataV4(
        keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ message: _message })))
    );
}
```
### **使用 OpenZeppelin 进行签名验证**
```solidity
function getSignerOZ(uint256 digest, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
    (address signer, /* ECDSA.RecoverError recoverError */, /* bytes32 signatureLength */ ) = ECDSA.tryRecover(digest, _v, _r, _s);
    return signer;
}
```
```solidity
function verifySignerOZ(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer) public pure returns (bool) {
    address actualSigner = getSignerOZ(getMessageHash(message), _v, _r, _s);
    require(actualSigner == signer);
    return true;
}
```

---

## **总结**
- **EIP 191**：标准化签名格式，支持代付交易。
- **EIP 712**：支持结构化数据，防止跨合约重放攻击，提升可读性。
- **OpenZeppelin**：提供便捷工具，简化 EIP 712 实现。

💡 **结论**：推荐使用 **EIP 712 + OpenZeppelin** 进行安全、可读性高的签名验证。