// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    address public tokenAddress;

    constructor(address _token) {
        require(address(0) != _token, "invalid token address");

        tokenAddress = _token;
    }

    function addLiquidity(uint256 _totolAmount) public payable {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _totolAmount);
    }

    function getReserve() public view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getAmount(
        uint256 inputAmount, // A->B, the amount of A
        uint256 inputReserve, // the amount of A in the contract/pool
        uint256 outputReserve // the amount of B in the contract/pool
    ) private pure returns(uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserve");
        return (outputReserve*inputAmount) / (inputReserve + inputAmount); // casuse slippage
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToTokenSwap(uint256 _minAmount) public payable {
        uint256 outputReserve = getReserve();
        uint tokenBought = getAmount(msg.value, address(this).balance - msg.value, outputReserve);

        require(tokenBought > _minAmount, "Unsatisfy the min amount of token");
        IERC20(tokenAddress).transferFrom(address(this), msg.sender, tokenBought);
    }

    function tokenToEth(uint256 _tokenSold , uint256 _minAmount) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(_tokenSold, tokenReserve, address(this).balance);

        require(ethBought > _minAmount, "Not enough ETH");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenSold);
        payable(msg.sender).transfer(ethBought);
    }


}