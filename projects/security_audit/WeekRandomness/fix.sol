// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.27;

// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// contract FixedRandomnessContract is VRFConsumerBase {
//     bytes32 internal keyHash;
//     uint256 internal fee;

//     constructor(
//         address _vrfCoordinator,
//         address _linkToken,
//         bytes32 _keyHash
//     ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
//         keyHash = _keyHash;
//         fee = 0.1 * 10 ** 18; // 0.1 LINK
//     }

//     function requestRandomNumber() public returns (bytes32 requestId) {
//         require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
//         return requestRandomness(keyHash, fee);
//     }
// }
