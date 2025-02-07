// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract FixedContract {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        // check
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // effect
        balances[msg.sender] = 0;

        // interaction
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
