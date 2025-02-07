// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract FixedSelfDestructMe {
    uint256 public totalDeposits;
    mapping(address => uint256) public deposits;

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw() external {
        /*
            The code has been changed to ensure the available ETH balance is _at least_ `totalDeposits`.
            This prevents DoS attacks via selfdestruct or external deposits.
        */
        require(
            address(this).balance >= totalDeposits,
            "Insufficient contract balance"
        ); // fixed

        uint256 amount = deposits[msg.sender];
        totalDeposits -= amount;
        deposits[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }
}
