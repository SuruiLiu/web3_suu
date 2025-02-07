// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract FixedContract {
    uint256[] public numbers;
    mapping(uint256 => bool) private numberExists; // Mapping to track existing numbers

    function addNumber(uint256 _number) public {
        // Only add the number if it doesn't already exist
        if (!numberExists[_number]) {
            numbers.push(_number); // Add the new number to the array
            numberExists[_number] = true; // Mark the number as existing
        }
    }

    function computeSum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            sum += numbers[i]; // Calculate the sum of all numbers
        }
        return sum; // Return the computed sum
    }
}
