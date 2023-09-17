// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply
        ) ERC20(_name, _symbol) payable {
        _mint(msg.sender, _supply * 10**uint256(_decimals));
    }
}