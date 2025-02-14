// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAccountAbstraction {
    // 账户所有者地址
    address public owner;
    
    // 用于社交恢复的守护者地址
    mapping(address => bool) public guardians;
    uint256 public numGuardians;
    uint256 public requiredGuardians;
    
    // 记录每日支出限额
    uint256 public dailyLimit;
    uint256 public lastDay;
    uint256 public spentToday;
    
    // 交易nonce，防重放
    uint256 public nonce;
    
    constructor(address _owner) {
        owner = _owner;
        lastDay = block.timestamp;
        // 设置默认每日限额为1 ETH
        dailyLimit = 1 ether;
        // 需要2个守护者确认才能恢复账户
        requiredGuardians = 2;
    }
    
    // 修改器：检查调用者是否为所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // 修改器：检查每日限额
    modifier withinLimit(uint256 amount) {
        if (block.timestamp > lastDay + 24 hours) {
            lastDay = block.timestamp;
            spentToday = 0;
        }
        require(spentToday + amount <= dailyLimit, "Daily limit exceeded");
        _;
    }
    
    // 执行交易
    function executeTransaction(
        address payable to,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) external withinLimit(value) returns (bool) {
        // 验证签名
        bytes32 txHash = keccak256(
            abi.encodePacked(to, value, data, nonce, address(this))
        );
        require(verifySignature(txHash, signature), "Invalid signature");
        
        nonce++;
        spentToday += value;
        
        // 执行交易
        (bool success, ) = to.call{value: value}(data);
        require(success, "Transaction failed");
        
        return success;
    }
    
    // 验证签名
    function verifySignature(bytes32 txHash, bytes memory signature) 
        internal view returns (bool) 
    {
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", txHash)
        );
        
        // 从签名中恢复地址
        address recovered = recoverSigner(ethSignedHash, signature);
        return recovered == owner;
    }
    
    // 从签名恢复签名者地址
    function recoverSigner(bytes32 ethSignedHash, bytes memory signature) 
        internal pure returns (address) 
    {
        require(signature.length == 65, "Invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
        return ecrecover(ethSignedHash, v, r, s);
    }
    
    // 添加守护者
    function addGuardian(address guardian) external onlyOwner {
        require(!guardians[guardian], "Already a guardian");
        guardians[guardian] = true;
        numGuardians++;
    }
    
    // 移除守护者
    function removeGuardian(address guardian) external onlyOwner {
        require(guardians[guardian], "Not a guardian");
        guardians[guardian] = false;
        numGuardians--;
    }
    
    // 设置每日限额
    function setDailyLimit(uint256 _limit) external onlyOwner {
        dailyLimit = _limit;
    }
    
    // 接收ETH
    receive() external payable {}
}