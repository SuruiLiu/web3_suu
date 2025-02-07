// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract VulnerableContract {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;

        // Attempt to send Ether to the caller
        (bool success, ) = msg.sender.call{value: amount}(""); // This can fail if msg.sender is a contract with a non-payable fallback
        require(success, "Transfer failed");
    }
}
