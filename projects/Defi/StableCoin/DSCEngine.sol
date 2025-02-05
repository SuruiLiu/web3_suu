// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.26;

// import { OracleLib, AggregatorV3Interface } from "./libraries/OracleLib.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { DecentralizedStableCoin } from "./DecentralizedStableCoin.sol";

// contract DSCEngine is ReentrancyGuard {
//     error DSCEngine_NeedsMoreThanZore();
//     error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
//     error DSCEngine_TokenNotAllowed(address token);
//     error DSCEngine_TransferFailed();
//     error DSCEngine_BreaksHealthFactor(uint256 healthFactor);
//     error DSCEngine_MintFaild();
//     error DSCEngine_HealthFactorOK();
//     error DSCEngine_HealthFactorNotImproved();

//     mapping(address token => address priceFeed) private s_priceFeeds;
//     mapping(address user => mapping(address token => uint256)) private s_collateralDeposit;
//     mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
//     DecentralizedStableCoin private immutable i_dsc;
//     address[] private s_collateralTokens;

//     uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
//     uint256 public constant PRECISION = 1e18;
//     uint256 public constant LIQUIDATION_THRESHOLD = 50;
//     uint256 public constant LIQUIDATION_PRECISION = 100;
//     uint256 public constant LIQUIDATION_BONUS = 10;
//     uint256 public constant MIN_HEALTH_FACTOR = 1e18;

//     event CollateralDeposit(address indexed user, address indexed token, uint256 indexed amount);
//     event CollateralRedeemed(address indexed redeemedFrom, address indexed redeemedTo, address indexed token, uint256 amount);

//     modifier moreThanZore(uint256 amount) {
//         if(amount <= 0) {
//             revert DSCEngine_NeedsMoreThanZore();
//         }
//         _;
//     }

//     modifier isAllowedToken(address token) {
//         if(s_priceFeeds[token] == address(0)) {
//             revert DSCEngine_TokenNotAllowed(token);
//         }
//         _;
//     }

//     constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
//         if(tokenAddresses.length != priceFeedAddresses.length){
//             revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
//         }
        
//         for(uint256 i = 0; i < tokenAddresses.length; i++) {
//             s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
//             s_collateralTokens.push(tokenAddresses[i]);
//         }
//         i_dsc = DecentralizedStableCoin(dscAddress);
//     }

//     function depositCollateralAndMintDsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToMint) external {
//         depositCollateral(tokenCollateralAddress, amountCollateral);
//         mintDsc(amountDscToMint);
//     }

//     function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) public moreThanZore(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
//         s_collateralDeposit[msg.sender][tokenCollateralAddress] += amountCollateral;
//         emit CollateralDeposit(msg.sender, tokenCollateralAddress, amountCollateral);

//         bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);

//         if(!success) {
//             revert DSCEngine_TransferFailed();
//         }
//     }

//     function redeemCollateralForDsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToBurn) external {
//         redeemCollateral(tokenCollateralAddress, amountCollateral);
//         burnDsc(amountDscToBurn);
//     }

//     function redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral) public moreThanZore(amountCollateral) nonReentrant{
//         _redeemCollateral(tokenCollateralAddress, amountCollateral, msg.sender, msg.sender);

//         _revertIfHealthFactorIsBroken(msg.sender);
//     }

//     function mintDsc(uint256 amountDscToMint) public moreThanZore(amountDscToMint) nonReentrant {
//         s_DSCMinted[msg.sender] = amountDscToMint;
//         _revertIfHealthFactorIsBroken(msg.sender);
//         bool minted = i_dsc.mint(msg.sender, amountDscToMint);

//         if(!minted) {
//             revert DSCEngine_MintFaild();
//         }
//     }

//     function burnDsc(uint256 amount) public moreThanZore(amount){
//         _burnDsc(amount, msg.sender, msg.sender);
//         _revertIfHealthFactorIsBroken(msg.sender);
//     }

//     function liquidate(address collateral, address user, uint256 debtToCover) external moreThanZore(debtToCover){
//         uint256 startingUserHealthFactor = _healthFactor(user);
//         if(startingUserHealthFactor > MIN_HEALTH_FACTOR) {
//             revert DSCEngine_HealthFactorOK();
//         }

//         uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(collateral, debtToCover);
//         uint256 bonusCollateral = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;

//         _redeemCollateral(collateral, tokenAmountFromDebtCovered + bonusCollateral, user, msg.sender);
//         _burnDsc(debtToCover, user, msg.sender);

//         uint256 endingUserHealthFactor = _healthFactor(user);
//         if(endingUserHealthFactor <= startingUserHealthFactor){
//             revert DSCEngine_HealthFactorNotImproved();
//         }

//         _revertIfHealthFactorIsBroken(msg.sender); // some system will be useful
//     }

//     function getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUsd){
//         for(uint256 i = 0; i < s_collateralTokens.length; i++) {
//             address token = s_collateralTokens[i];
//             uint256 amount = s_collateralDeposit[user][token];
//             totalCollateralValueInUsd += getUsdValue(token, amount);
//         }
//         return totalCollateralValueInUsd;
//     }

//     function getUsdValue(address token, uint256 amount) public view returns(uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]); // get the token's Aggregator
//         (,int256 price,,,) = priceFeed.latestRoundData();

//         return  ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION; // the price returned decimal is 8 and need transfer to uint256 
//     }

//     function getTokenAmountFromUsd(address token, uint256 usdAmountInWei) public view returns(uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
//         (, int256 price,,,) = priceFeed.latestRoundData();

//         return (usdAmountInWei * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION);
//     }

//     function _revertIfHealthFactorIsBroken(address user) internal view {
//         uint256 userHealthFactor = _healthFactor(user);
//         if(userHealthFactor < MIN_HEALTH_FACTOR) {
//             revert DSCEngine_BreaksHealthFactor(userHealthFactor);
//         }
//     }

//     function _healthFactor(address user) private view returns(uint256){
//         (uint256 totalDscMinted, uint256 collateralValuedInUsd) = _getAccountInformation(user);
//         uint256 collateralAjustedForThreshold = (collateralValuedInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
//         return (collateralAjustedForThreshold * PRECISION) / totalDscMinted;
//     }

//     function _getAccountInformation(address user) private view returns(uint256 totalDscMinted, uint256 collateralValueInUsd) {
//         totalDscMinted = s_DSCMinted[user];
//         collateralValueInUsd = getAccountCollateralValue(user);
//     }

//     function _redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral, address from, address to) private {
//         s_collateralDeposit[from][tokenCollateralAddress] -= amountCollateral;
//         emit CollateralRedeemed(from, to, tokenCollateralAddress, amountCollateral);

//         bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
//         if(!success) {
//             revert DSCEngine_TransferFailed();
//         }
//     }

//     function _burnDsc(uint256 amount, address onBehalfOf, address dscFrom) private moreThanZore(amount){
//         s_DSCMinted[onBehalfOf] -= amount;
//         bool success = i_dsc.transferFrom(dscFrom, address(this), amount);
//         if(!success) {
//             revert DSCEngine_TransferFailed();
//         }
//         i_dsc.burn(amount);
//     }

//     function getPrecision() external pure returns (uint256) {
//         return PRECISION;
//     }

//     function getAdditionalFeedPrecision() external pure returns (uint256) {
//         return ADDITIONAL_FEED_PRECISION;
//     }

//     function getLiquidationThreshold() external pure returns (uint256) {
//         return LIQUIDATION_THRESHOLD;
//     }

//     function getLiquidationBonus() external pure returns (uint256) {
//         return LIQUIDATION_BONUS;
//     }

//     function getLiquidationPrecision() external pure returns (uint256) {
//         return LIQUIDATION_PRECISION;
//     }

//     function getMinHealthFactor() external pure returns (uint256) {
//         return MIN_HEALTH_FACTOR;
//     }

//     function getCollateralTokens() external view returns (address[] memory) {
//         return s_collateralTokens;
//     }

//     function getDsc() external view returns (address) {
//         return address(i_dsc);
//     }

//     function getCollateralTokenPriceFeed(address token) external view returns (address) {
//         return s_priceFeeds[token];
//     }

//     function getHealthFactor(address user) external view returns (uint256) {
//         return _healthFactor(user);
//     }
// }