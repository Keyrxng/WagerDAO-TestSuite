import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";
import {Scores} from "./mocks/Scores.sol";

contract ScoresBasicTest is InitSetup {
    function setUp() public override {
        super.setUp();
        // team0 has 50ETH
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }

    function test_cScoresState() external {
        vm.startPrank(team0);
        assertEq(cScores.name(), "Scores");
        assertEq(cScores.symbol(), "SCORE");
        assertEq(cScores.decimals(), 9);
        assertEq(cScores.totalSupply(), 1_000_000_000 * 1e9);
        assertEq(cScores.buyTaxes(), 470);
        assertEq(cScores.sellTaxes(), 470);
        assertEq(cScores.divider(), 1000);
        assertEq(cScores.maxTxAmount(), 10_000_001 * 1e9);
        assertEq(cScores.maxWalletAmount(), 10_000_001 * 1e9);
        assertEq(cScores._isExcludedFromFee(address(uniswapV2Router)), true);
        assertEq(cScores._isExcludedFromFee(team0), true);
        assertEq(cScores._isExcludedFromFee(address(cTreasury)), false);
        assertEq(cScores.canTransferBeforeLaunch(address(team0)), true);
        assertEq(cScores.treasuryAddress(), address(cTreasury));
        assertEq(cScores.swapThrehold(), 200_000 * 1e9);
        assertEq(cScores.treasuryShare(), 70);
        assertEq(cScores.liquidityShare(), 30);
        assertEq(cScores.isItLaunched(), false);
        assertEq(cScores.autoSwapEnabled(), true);
        cScores.setUniPair(address(uniV2Pair));
        assertEq(cScores.uniswapV2Pair(), address(uniV2Pair));
        assertEq(address(cScores.uniswapV2Router()), address(uniswapV2Router));
        vm.stopPrank();
    }

    function test_cScores_NoAuth() external {
        vm.startPrank(user0);

        vm.expectRevert();
        cScores.preLaunchTransfer(user1, true);

        vm.expectRevert();
        cScores.updatePair(user1);

        vm.expectRevert();
        cScores.launch();

        vm.expectRevert();
        cScores.manualSendToTreasury();

        vm.expectRevert();
        cScores.withdrawETH();

        vm.expectRevert();
        cScores.changeTreasuryAddress(user0);

        vm.expectRevert();
        cScores.changeTaxes(99, 1);

        vm.expectRevert();
        cScores.changeSwapSettings(false, 10, 99, 1);

        vm.expectRevert();
        cScores.changeMaxTxAmount(1000000000000000000);

        vm.expectRevert();
        cScores.excludeFromFee(user0, true);

        vm.expectRevert();
        cScores.changeMaxWalletAmount(10000000000000000000);

        vm.stopPrank();
    }

    function test_cScores_WAuth() external {
        vm.startPrank(team0);

        cScores.excludeFromFee(user0, true);
        assertEq(cScores._isExcludedFromFee(user0), true);

        cScores.preLaunchTransfer(user1, true);
        assertEq(cScores.canTransferBeforeLaunch(user1), true);

        cScores.transfer(user0, 100 * 1e9);
        cScores.transfer(address(cTreasury), 1000 * 1e9);

        cScores.launch();
        assertEq(cScores.isItLaunched(), true);

        cScores.manualSendToTreasury();
        assertEq(cScores.balanceOf(address(cTreasury)), 1000 * 1e9);

        vm.deal(address(cScores), 100 ether);
        uint bal = team0.balance;
        cScores.withdrawETH();
        assertEq(team0.balance, bal + 100 ether);

        cScores.changeTreasuryAddress(address(this));
        assertEq(cScores.treasuryAddress(), address(this));

        cScores.changeTaxes(99, 1);
        assertEq(cScores.buyTaxes(), 99);
        assertEq(cScores.sellTaxes(), 1);

        cScores.changeSwapSettings(false, 10, 99, 1);
        assertEq(cScores.autoSwapEnabled(), false);
        assertEq(cScores.swapThrehold(), 10 * 1e9);
        assertEq(cScores.treasuryShare(), 99);
        assertEq(cScores.liquidityShare(), 1);

        cScores.changeMaxTxAmount(1000000000000000000);
        assertEq(cScores.maxTxAmount(), 1000000000000000000);

        cScores.updatePair(user1);
        assertEq(cScores.uniswapV2Pair(), address(user1));

        cScores.changeMaxWalletAmount(10000000000000000000);
        assertEq(cScores.maxWalletAmount(), 10000000000000000000);

        

        vm.stopPrank();
    }
}

contract ScoresDeepTest is InitSetup {
    function setUp() public override {
        super.setUp();
        vm.startPrank(team0);
        cScores.launch();
        cScores.transfer(user0, 10_000 * 1e9);
        cScores.transfer(user1, 10_000 * 1e9);
        cScores.transfer(address(cTreasury), 1_000_000 * 1e9);

        vm.deal(address(cTreasury), 5 ether);
        vm.deal(user0, 2 ether);
        vm.deal(user1, 2 ether);
        vm.deal(team1, 2 ether);

        vm.stopPrank();
    }

    //////////// Helpers ////////////

    function tokensForEth(
        address[] memory path,
        uint amount,
        address receiver
    ) public {
        Scores(payable(path[0])).approve(address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // slippage 100%
            path,
            receiver,
            block.timestamp
        );
    }

    function ethForTokens(
        address[] memory path,
        uint amount,
        address receiver
    ) public {
        WETH.approve(address(uniswapV2Router), amount);
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // slippage 100%
            path,
            receiver,
            block.timestamp
        );
    }

    function spawnTradingActivity() public {
        vm.deal(user1, 5 ether);
        vm.deal(user0, 5 ether);
        vm.deal(user1, 5 ether);
        vm.prank(address(cTreasury));
        cScores.transfer(address(cScores), 1_000_000 * 1e9);
        address[] memory path = new address[](2);
        path[1] = address(cScores);
        path[0] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

        vm.prank(user1);
        ethForTokens(path, 1 ether / 2, user1);
        vm.prank(user0);
        ethForTokens(path, 1 ether / 2, user0);
        vm.prank(team1);
        ethForTokens(path, 1 ether / 2, team1);
        vm.prank(user1);
        ethForTokens(path, 1 ether / 2, user1);
        vm.prank(user0);
        ethForTokens(path, 1 ether / 2, user0);
        vm.prank(team1);
        ethForTokens(path, 1 ether / 2, team1);
        vm.prank(user1);
        ethForTokens(path, 1 ether / 2, user1);
        vm.prank(user0);
        ethForTokens(path, 1 ether / 2, user0);
        console.log("Max Wallet Limit reached");
    }

    //////////// Tests ////////////

    function test_cScores_SellingFees() external {
        vm.startPrank(user0);
        address[] memory path = new address[](2);
        path[0] = address(cScores);
        path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

        uint user0EthBal = user0.balance;
        uint cScoresBal = cScores.balanceOf(address(cScores));
        uint user0SBal = cScores.balanceOf(user0);
        uint tradeSize = user0SBal / 2;

        assertTrue(tradeSize < cScores.maxTxAmount());
        assertTrue(tradeSize < cScores.maxWalletAmount());

        /**
            Pre Trade Balances:
            CScores Bal: 0 score
            User Scores bal: 10,000 score
            User Eth Bal: 2 ether
            Trade Size: 5,000 score
            Trade Fee: 5,000 * 30 / 1000 = 150 score
            Fee: 3%
         */
        tokensForEth(path, user0SBal / 2, user0);
        /**
            Post Trade Balances:
            CScores Bal: 150 score
            User Scores bal: 5,000 score
            User Eth Bal: 2.0008 ether
         */

        assertTrue(user0.balance > user0EthBal);
        assertEq(cScores.balanceOf(user0), user0SBal - tradeSize);
        assertEq(
            cScores.balanceOf(address(cScores)),
            cScoresBal + ((tradeSize * 30) / 1000)
        );
    }

    function test_cScores_BuyingFees() external {
        vm.startPrank(user0);
        address[] memory path = new address[](2);
        path[0] = address(cScores);
        path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

        (path[0], path[1]) = (path[1], path[0]);

        uint user0EthBal = user0.balance;
        uint cScoresBal = cScores.balanceOf(address(cScores));
        uint user0SBal = cScores.balanceOf(user0);
        uint tradeSize = user0SBal / 2;

        assertTrue(tradeSize < cScores.maxTxAmount());
        assertTrue(tradeSize < cScores.maxWalletAmount());

        /**
            Pre Trade Balances:
            CScores Bal: 0 score
            User Scores bal: 10,000 score
            User Eth Bal: 2 ether
            Trade Size: 5,000 score
            Trade Fee: 5,000 * 30 / 1000 = 150 score
            Fee: 3%      
         
            Given an output asset amount and an array of token addresses, 
            calculates all preceding minimum input token amounts by calling getReserves
            for each pair of token addresses in the path in turn, and using these to call getAmountIn.
            Useful for calculating optimal token amounts before calling swap.
        */
        uint amountsIn = uniswapV2Router.getAmountsIn(tradeSize, path)[0];
        ethForTokens(path, amountsIn, user0);

        assertTrue(user0.balance < user0EthBal);
        assertEq(
            cScores.balanceOf(user0),
            user0SBal + tradeSize - ((tradeSize * 30) / 1000)
        );
        assertEq(
            cScores.balanceOf(address(cScores)),
            cScoresBal + ((tradeSize * 30) / 1000)
        );
    }

    function test_cScores_OpenedAutoLiquidity() external {
        address[] memory path = new address[](2);
        path[0] = address(cScores);
        path[1] = uniswapV2Router.WETH();       
        
        vm.prank(address(cTreasury));
        cScores.transfer(address(cScores), 1_000_000 * 1e9);

        vm.startPrank(team0);
        uint initBal = address(cScores).balance;
        uint cScoresbal = cScores.balanceOf(address(cScores));
        uint pairbalance = cScores.balanceOf(address(uniV2Pair));
        uint pairEth = WETH.balanceOf(address(uniV2Pair));
        (uint112 r0, uint112 r1, uint32 timestamp) = uniV2Pair.getReserves();

        assertEq(pairbalance, r0);
        assertEq(pairEth, r1);

        uint tForLiq = cScoresbal * 30 / 100;

        uint half = tForLiq / 2;
        cScores._swapTokensForEth(half);

        uint newEthBal = address(cScores).balance;
        assertGt(newEthBal, initBal);

        (uint ethReserve, uint tokenReserve, ) = uniV2Pair.getReserves();
        console.log("reserves: ", ethReserve, tokenReserve, timestamp);

        cScores._addLiquidity(half, newEthBal - initBal);

        (r0, r1, timestamp) = uniV2Pair.getReserves();
        console.log("reserves: ", r0, r1, timestamp);

        assertGt(r0, ethReserve);
        assertGt(r1, tokenReserve);
    }

    function test_cScores_ClosedAutoLiquidity() external {
        address[] memory path = new address[](2);
        path[0] = address(cScores);
        path[1] = uniswapV2Router.WETH();       
        
        vm.prank(address(cTreasury));
        cScores.transfer(address(cScores), 1_000_000 * 1e9);

        uint initBal = address(cScores).balance;
        uint pairbalance = cScores.balanceOf(address(uniV2Pair));
        uint pairEth = WETH.balanceOf(address(uniV2Pair));
        uint ethPair = address(uniV2Pair).balance;
        uint cScoresBal = cScores.balanceOf(address(cScores));
        uint tForLiq = cScoresBal * 30 / 100;
        (uint112 r0, uint112 r1, uint32 timestamp) = uniV2Pair.getReserves();

        assertEq(pairbalance, r0);
        assertEq(pairEth, r1);

        vm.prank(address(cScores));

        cScores.swapAndAddLiquidity(tForLiq);
        (r0, r1, timestamp) = uniV2Pair.getReserves();

        assertGt(r0, pairbalance);
        uint newPairbalance = cScores.balanceOf(address(uniV2Pair));
        uint newPairEth = WETH.balanceOf(address(uniV2Pair));
        uint newScoresBal = cScores.balanceOf(address(cScores));
        uint newEthPair = address(uniV2Pair).balance;

        assertGt(newPairbalance, pairbalance);
        assertLt(newScoresBal, cScoresBal);
        assertEq(newPairbalance, r0);
        assertEq(newPairEth, r1);
    }

    function test_cScores_TradingActivity() external {
        uint initScoresBal = cScores.balanceOf(address(cScores));
        uint initPairBal = cScores.balanceOf(address(uniV2Pair));
        uint initPairEth = WETH.balanceOf(address(uniV2Pair));

        spawnTradingActivity();

        uint newScoresBal = cScores.balanceOf(address(cScores));
        uint newPairBal = cScores.balanceOf(address(uniV2Pair));
        uint newPairEth = WETH.balanceOf(address(uniV2Pair));

        assertGt(newScoresBal, initScoresBal);    
        assertLt(newPairBal, initPairBal);
        assertGt(newPairEth, initPairEth);
    }

    function test_cScores_SwapforEthWithShares() external {
        uint contractBal = cScores.balanceOf(address(cTreasury));
        uint teamCoin = contractBal * 60 / 100;
        uint allMembers = 6;
        uint memberShare = teamCoin / allMembers;
        assertEq(memberShare, teamCoin / 6);

        vm.prank(address(cScores));
        cTreasury.distributeFeeTokens();

        assertEq(cTreasury.totalTeamScorePaid(), memberShare * allMembers);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(1)), memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(2)), memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(3)), memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(4)), memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(5)), memberShare);
    }

}
