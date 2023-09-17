// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface NFTInterface {
     function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
     function balanceOf(address account) external view returns (uint256);
     function totalSupply() external view returns (uint256);
}