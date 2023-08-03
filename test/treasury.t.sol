// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Scores} from "./mocks/Scores.sol";
import {WagerDAOTreasury} from "./mocks/Treasury.sol";
import {betManagerV04} from "./mocks/betManager.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../src/interfaces/IUniV2Factory.sol";
import {InitSetup} from "./setups/InitSetup.sol";
import "forge-std/Console.sol";



contract TreasuryTest is InitSetup {

    ERC20Mock token;
    IUniswapV2Pair tempPair;

    function setUp() public override {
        super.setUp();
        vm.startPrank(team0);
        cScores.launch();        
        cTreasury.setScoreToken(address(cScores));
        assertEq(cTreasury.scoreToken(), address(cScores));
        cScores.transfer(address(cTreasury), cScores.balanceOf(team0));

        token = new ERC20Mock("Key", "rxng", 9, 1_000_000_000);
        
        token.transfer(address(cTreasury), 300_000_000 * 10**9);
        token.approve(address(cTreasury), 300_000_000 * 10**9);
        token.approve(address(uniswapV2Router), 300_000_000 * 10**9);
        tempPair = IUniswapV2Pair(uniswapV2Factory.createPair(address(token), address(WETH)));
        token.approve(address(tempPair), 300_000_000 * 10**9);

        // solhint-disable-next-line
        (uint256 a ,uint256 b ,uint256 l ) = uniswapV2Router
        .addLiquidityETH{value:50 ether}(
            address(token),
            300_000_000 * 10**9,
            0,
            0,
            team0,
            block.timestamp + 100
        );

    }

    function test_SwapScoreForEth() external {
        uint256 scoreBalance = cScores.balanceOf(address(cTreasury));
        uint256 ethBalance = address(cTreasury).balance;

        cTreasury._swapScoreTokensForEth(1000000);

        uint newScoreBalance = cScores.balanceOf(address(cTreasury));
        uint newEthBalance = address(cTreasury).balance;

        assertEq(newScoreBalance, scoreBalance - 1000000 * 1e9);
        assertTrue(newEthBalance != ethBalance);
    }

    function test_anyTokenForEth() external {
        uint256 tokenBalance = token.balanceOf(address(cTreasury));
        uint256 ethBalance = address(cTreasury).balance;

        cTreasury.swapAnyTokenForEth(address(token), 1000000); // contract doesn't the * 1e9
        
        uint newTokenBalance = token.balanceOf(address(cTreasury));
        uint newEthBalance = address(cTreasury).balance;

        assertEq(newTokenBalance, tokenBalance - 1000000);
        assertTrue(newEthBalance != ethBalance);
    }

    function test_WithdrawEth() external {
        vm.deal(address(cTreasury), 100 ether);
        uint256 ethBalance = address(cTreasury).balance;
        assertEq(ethBalance, 100 ether);

        cTreasury.withdrawETH();

        uint newEthBalance = address(cTreasury).balance;
        assertEq(newEthBalance, 0);
    }

    function test_WithdrawScore() external {
        uint256 scoreBalance = cScores.balanceOf(address(cTreasury));
        assertEq(scoreBalance, 700_000_000 * 10**9);
        cTreasury.withdrawScoreToken();

        uint newScoreBalance = cScores.balanceOf(address(cTreasury));
        assertEq(newScoreBalance, 0);
    }

    function test_withdrawAnyToken() external {
        uint256 tokenBalance = token.balanceOf(address(cTreasury));
        assertEq(tokenBalance, 300_000_000 * 10**9);

        cTreasury.withdrawAnyToken(address(token));

        uint newTokenBalance = token.balanceOf(address(cTreasury));
        assertEq(newTokenBalance, 0);
    }

    function test_payToMarketingPartnerWithETH() external {
        vm.deal(address(cTreasury), 100 ether);
        uint256 ethBalance = address(cTreasury).balance;
        assertEq(ethBalance, 100 ether);

        cTreasury.payToMarketingPartnerWithETH("Keyrxng", user2, 50);

        uint newEthBalance = address(cTreasury).balance;
        assertEq(user2.balance, 50 * 1e16);
        assertEq(newEthBalance, 100 ether - 50 * 1e16);

        /**
            * Treasury contract is using 1e16 for ether when it should be 1e18
            * use '* 1 ether' or '1e18' instead of '* 1e16' to fix 
         */
    }

    function test_payToMarketingPartnerWithScore() external {
        uint256 scoreBalance = cScores.balanceOf(address(cTreasury));

        address temp = makeAddr("temp");

        cTreasury.payToMarketingPartnerWithScore("Keyrxng", temp, 1000000);

        uint newScoreBalance = cScores.balanceOf(address(cTreasury));

        assertEq(cScores.balanceOf(temp), 1000000 * 1e9);
        assertEq(newScoreBalance, scoreBalance - 1000000 * 1e9);
    }

    function test_Setters() external {
        assertEq(cTreasury.scoreToken(), address(cScores));
        assertEq(cTreasury.receiver(), address(cTreasury));

        cTreasury.setScoreToken(address(token));
        assertEq(cTreasury.scoreToken(), address(token));

        cTreasury.setSwapReceiver(user2);
        assertEq(cTreasury.receiver(), user2);
    }


}