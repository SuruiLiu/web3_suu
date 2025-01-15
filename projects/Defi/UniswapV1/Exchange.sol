// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IExchange {
    function ethToTokenSwap(uint256 _minTokens) external payable;

    function ethToTokenTransfer(uint256 _minTokens, address _recipient)
        external
        payable;
}

interface IFactory {
  function getExchange(address _tokenAddress) external returns (address);
}

contract Exchange is ERC20{
    address public tokenAddress;
    address public factoryAddress;

    constructor(address _token) ERC20("Uniswap-v1", "UV1"){
        require(address(0) != _token, "invalid token address");

        tokenAddress = _token;
        factoryAddress = msg.sender;
    }

    function addLiquidity(uint256 _totolAmount) public payable returns (uint256){ // payable means transfer some eth
        if(getReserve() == 0){
            IERC20 token = IERC20(tokenAddress);
            token.transferFrom(msg.sender, address(this), _totolAmount);

            uint256 liquidity = address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        } else {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = getReserve();
            uint256 ethAmount = msg.value;
            uint256 tokenAmount = (ethAmount * tokenReserve) / ethReserve; 
            // not depositing all tokens provided by user 
            // but only an amount calculated based on current reserves ratio

            require(_totolAmount > tokenAmount, "Not enough token amount");
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);

            uint256 liquidity = (totalSupply() * msg.value) / address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        }
        
    }

    function removeLiquidity(uint256 _amount) public returns(uint256, uint256) {
        require(_amount > 0 , "invalid amount");
        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();
        uint256 tokenAmount = (getReserve() *_amount) / totalSupply();

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        IERC20(tokenAddress).transferFrom(address(this), msg.sender, tokenAmount);
        return (ethAmount, tokenAmount);    
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
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
        // return (outputReserve*inputAmount) / (inputReserve + inputAmount); // casuse slippage
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

    function ethToToken(uint256 _minTokens, address recipient) private {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = getAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(tokensBought >= _minTokens, "insufficient output amount");

        IERC20(tokenAddress).transfer(recipient, tokensBought);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        ethToToken(_minTokens, msg.sender);
    }

    function ethToTokenTransfer(uint256 _minTokens, address _recipient)
        public
        payable
    {
        ethToToken(_minTokens, _recipient);
    }

    function tokenToEth(uint256 _tokenSold , uint256 _minAmount) public payable {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(_tokenSold, tokenReserve, address(this).balance);

        require(ethBought > _minAmount, "Not enough ETH");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenSold);
        payable(msg.sender).transfer(ethBought);
    }

    function tokenToTokenSwap(
        uint256 _tokensSold,
        uint256 _minTokensBought,
        address _tokenAddress
    ) public { 
        address exchangeAddress = IFactory(factoryAddress).getExchange(_tokenAddress);
        require(exchangeAddress != address(this) && exchangeAddress != address(0), "invalid address");

        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );

        // IExchange(exchangeAddress).ethToTokenSwap{value: ethBought}(_minTokensBought); // transer to factory
        IExchange(exchangeAddress).ethToTokenTransfer{value: ethBought}(
            _minTokensBought,
            msg.sender
        );
    }


}