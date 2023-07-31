// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Scores} from "../src/Scores.sol";
import {WagerDAOTreasury} from "../src/Treasury.sol";
import {betManagerV04} from "../src/betManager.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../src/interfaces/IUniV2Factory.sol";
import {BaseSetup} from "./setups/baseSetup.sol";

import "forge-std/Console.sol";

contract ScoresTest is BaseSetup {
    
    function setUp() override public {
        super.setUp();
    }

}