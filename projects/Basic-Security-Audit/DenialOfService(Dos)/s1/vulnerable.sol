//SPDX-License-Identifier: MIT

// Vulnerable Smart Contract
// Senario: check if the new _number has been added
pragma solidity ^0.8.27;

contract DoSVulnerableContract {
    uint256[] public numbers;

    // When the numbers become huge the gas costed become huge causing Dos
    function addNumber(uint256 _number) public {
        for (uint256 i; i < numbers.length; i++) {
            if (numbers[i] != _number) {
                numbers.push(_number);
            }
        }
    }

    function computeSum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }
        return sum;
    }
}
