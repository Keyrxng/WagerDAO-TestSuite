// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ITreasury {
    function distributeETHfeeTokens(uint256 coins) external;
    function failedEthTeamTokens(uint256 coins) external;
    function distributeFeeTokens(uint256 tokens) external;
}