// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract OverflowFixed {
    uint8 public count;

    // Solidity 0.8+ automatically checks for overflow
    function increment(uint8 amount) public {
        count = count + amount;
        require(count >= amount, "Overflow occurred");
    }
}

contract UnderflowFixed {
    uint8 public count;

    // Solidity 0.8+ automatically checks for underflow
    function decrement() public {
        require(count > 0, "Underflow occurred");
        count--;
    }
}

contract PrecisionLossFixed {
    uint256 public moneyToSplitUp = 225;
    uint256 public users = 4;

    // This function returns a more precise result by using fixed-point arithmetic
    function shareMoney() public view returns (uint256) {
        return (moneyToSplitUp * 100) / users; // Result is scaled up by 100
    }

    // Optional: Function to return the result as a floating-point string
    function shareMoneyWithDecimals()
        public
        view
        returns (uint256 remainder, uint256 quotient)
    {
        remainder = moneyToSplitUp % users;
        quotient = moneyToSplitUp / users;
    }
}
