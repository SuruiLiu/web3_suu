// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Exchange.sol";

contract Factory {
    mapping (address => address) tokenToExchange;

    function createExchange(address _tokenAddress) public returns(address) {
        require(_tokenAddress != address(0), "invalid token address");
        require(tokenToExchange[_tokenAddress] == address(0), "Exchange already exists");

        Exchange exchange = new Exchange(_tokenAddress);
        tokenToExchange[_tokenAddress] = address(exchange);

        return address(exchange);
    }

    function getExchange(address _tokenAddress) public view returns (address) {
        return tokenToExchange[_tokenAddress];
    }
}