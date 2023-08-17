// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test} from "forge-std/Test.sol";
// import {InitSetup} from "./setups/InitSetup.sol";
// import "forge-std/Console.sol";

// contract ScoresTest is InitSetup {

//     uint256 private buyTaxes = 470;
//     uint256 private sellTaxes = 470;
//     uint256 private divider = 1000;

//     uint256 private maxTxAmount = 10000001 * 1e9;
//     uint256 private maxWalletAmount = 10000001 * 1e9;

//     uint256 public swapThrehold = 200000 * 1e9;
//     uint256 private treasuryShare = 70;
//     uint256 private liquidityShare = 30;
    

//     function setUp() public override {
//         super.setUp();
//         vm.deal(user1, 5 ether);
//         vm.startPrank(team0);
//         cScores.launch();
        
//     }

//     // function test_PostLaunch() external {
//     //     // Tests that the postLaunch function works as intended

//     //     uint newBuyTaxes = 30;
//     //     uint newSellTaxes = 30;
//     //     uint newMaxTxAmount = 10_000_001 * 1e9; // no different from initial value
//     //     uint newMaxWalletAmount = 10_000_001 * 1e9; // no different from initial value

//     //     (uint initBuyTax, uint initSellTax) = cScores.currentTaxes();
//     //     (uint initMaxTxAmount, uint initMaxWalletAmount) = cScores
//     //         .currentLimits();

//     //     assertEq(initBuyTax, buyTaxes);
//     //     assertEq(initSellTax, sellTaxes);
//     //     assertEq(initMaxTxAmount, maxTxAmount);
//     //     assertEq(initMaxWalletAmount, maxWalletAmount);

//     //     // cScores.postLaunch();

//     //     (uint newBuyTax, uint newSellTax) = cScores.currentTaxes();
//     //     (uint updatedTxAmount, uint updatedMaxWalletAmount) = cScores
//     //         .currentLimits();

//     //     assertEq(newBuyTax, newBuyTaxes);
//     //     assertEq(newSellTax, newSellTaxes);
//     //     assertEq(updatedTxAmount, newMaxTxAmount);
//     //     assertEq(updatedMaxWalletAmount, newMaxWalletAmount);

//     //     assertTrue(newBuyTax != initBuyTax);
//     //     assertTrue(newSellTax != initSellTax);
//     //     // assertTrue(updatedTxAmount != initMaxTxAmount); // fails due to value unchanged
//     //     // assertTrue(updatedMaxWalletAmount != initMaxWalletAmount); // fails due to value unchanged
//     //     vm.stopPrank();
//     // }

//     function test_TradingWorks() external {
//         // Tests that AMM trading works at least once
//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);
//         address to = payable(team1);
//         uint deadline = block.timestamp + 1000000000;
//         uint balBeforeTrade = cScores.balanceOf(team0);
//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             100000,
//             0,
//             path,
//             to,
//             deadline
//         );
//         uint balAfterTrade = cScores.balanceOf(team0);

//         assertTrue(balAfterTrade < balBeforeTrade);
//         uint ethBal = team0.balance;

//         path[0] = address(WETH);
//         path[1] = address(cScores);

//         uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
//             value: 1e9
//         }(0, path, to, deadline);
//         uint ethBalAfter = team0.balance;
//         assertTrue(ethBalAfter < ethBal);
//     }

//     function testFail_TradingMaxTxAmount() external {
//         // Tests that trading restrictions are enforced
//         // maxTxAmount is 10_000_001_000_000_000
//         //    trade size  700_000_000_000_000_000
//         // this should fail but it doesn't
//         // user1 is not excluded from fees or size restrictions

//         cScores.transfer(user1, cScores.balanceOf(team0));
//         vm.stopPrank();
//         vm.startPrank(user1);
//         cScores.approve(address(uniswapV2Router), cScores.balanceOf(user1));

//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);

//         address to = payable(user1);
//         uint deadline = block.timestamp + 1000000000;
//         uint balBeforeTrade = cScores.balanceOf(user1);
//         console.log("User1 balance before trade: ", balBeforeTrade);
//         console.log("Max transaction: ", cScores.maxTxAmount());
//         assertTrue(cScores.maxTxAmount() >= balBeforeTrade);

//         vm.expectRevert(); // max tx amount reached
//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             balBeforeTrade, // 700_000_000_000_000_000
//             0,
//             path,
//             to,
//             deadline
//         );
       

//     }

//     function test_TradingSellFees() external {
//         // Tests that trading fees are collected and distributed correctly
//         // Balance before: 700000000000000000
//         // Balance after:  699900000000000000

//         // Trade size:     100_000_000_000_000
//         // Tax Amount:     47_000_000_000_000
//         // Trade - Tax =   53_000_000_000_000

//         // Trades take 47% of the trade amount as tax
        
//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);
//         cScores.transfer(user1, cScores.balanceOf(team0));
//         vm.stopPrank();
//         vm.startPrank(user1);
//         cScores.approve(address(uniswapV2Router), cScores.balanceOf(user1));

//         address to = payable(user1);
//         uint deadline = block.timestamp + 1000000000;

//         uint balBeforeTrade = cScores.balanceOf(user1);
//         uint ethBalBefore = user1.balance;
//         uint scoresOwnBalanceBefore = cScores.balanceOf(address(cScores));

//         uint toV2PairTaxAmount = 100000 * 1e9 * sellTaxes / divider;
//         uint fromV2PairTaxAmount = 100000 * 1e9 * buyTaxes / divider;

//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             100000 * 1e9,
//             0,
//             path,
//             to,
//             deadline
//         );

//         uint balAfterTrade = cScores.balanceOf(user1);
//         uint ethBalAfter = user1.balance;
//         uint scoresOwnBalanceAfter = cScores.balanceOf(address(cScores));
        
//         assertTrue(ethBalAfter > ethBalBefore);
//         assertTrue(balAfterTrade < balBeforeTrade);
//         assertEq(toV2PairTaxAmount, fromV2PairTaxAmount); // taxes are the same for buy and sell
        
//         assertEq(balAfterTrade, balBeforeTrade - 100000 * 1e9);
//         assertEq(scoresOwnBalanceAfter, scoresOwnBalanceBefore + toV2PairTaxAmount);
//         assertEq(scoresOwnBalanceAfter, toV2PairTaxAmount);
//     }

//     function test_TradingBuyFees() external {
//         // Tests that trading fees are collected and distributed correctly
//         // Balance before: 5000000000000000000
//         // Balance after:  4999900000000000000

//         // Trade size:     598_798_804_797
//         // cScores bought: 598_798_804_797
//         // Tax Amount:     281_435_438_254
//         // Trade - Tax =   317_363_366_543

//         // Trades take 47% of the trade amount as tax
        
//         address[] memory path = new address[](2);
//         path[0] = address(WETH);
//         path[1] = address(cScores);
        
//         vm.stopPrank();
//         vm.startPrank(user1);
        
//         WETH.approve(address(uniswapV2Router), WETH.balanceOf(user1));
        
//         address to = payable(user1);
//         uint deadline = block.timestamp + 1000000000;

//         uint balBeforeTrade = cScores.balanceOf(user1);
//         uint ethBalBefore = user1.balance;
//         uint scoresOwnBalanceBefore = cScores.balanceOf(address(cScores));

//         uint toV2PairTaxAmount = 598_798_804_797 * sellTaxes / divider;
//         uint fromV2PairTaxAmount = 598_798_804_797 * buyTaxes / divider;

//         uint[] memory getAmountsOut = uniswapV2Router.getAmountsOut(100000 * 1e9, path);

//         uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
//             value: 100000 * 1e9
//         }(0, path, to, deadline);

//         uint balAfterTrade = cScores.balanceOf(user1);
//         uint ethBalAfter = user1.balance;
//         uint scoresOwnBalanceAfter = cScores.balanceOf(address(cScores));
       
//         assertTrue(ethBalAfter < ethBalBefore);
//         assertTrue(balAfterTrade > balBeforeTrade);
//         assertEq(toV2PairTaxAmount, fromV2PairTaxAmount); // taxes are the same for buy and sell

//         assertEq(balAfterTrade, balBeforeTrade + 317_363_366_543);
//         assertEq(scoresOwnBalanceAfter, scoresOwnBalanceBefore + toV2PairTaxAmount);
//         assertEq(scoresOwnBalanceAfter, toV2PairTaxAmount);
//     }

//     function test_AutoSwapMemberFees() external {
//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);
//         cScores.transfer(user1, cScores.balanceOf(team0));
//         vm.stopPrank();
//         vm.startPrank(user1);
//         cScores.approve(address(uniswapV2Router), type(uint).max);

//         address to = payable(user1);
//         uint deadline = block.timestamp + 1000000000;

//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             cScores.balanceOf(user1) / 2,
//             0,
//             path,
//             to,
//             deadline
//         );

//         // uint member2BalBefore = cScores.balanceOf(cScores.member2());
//         // uint member3BalBefore = cScores.balanceOf(cScores.member3());
//         // uint member4BalBefore = cScores.balanceOf(cScores.member4());
//         // uint member5BalBefore = cScores.balanceOf(cScores.member5());
//         // uint member6BalBefore = cScores.balanceOf(cScores.member6());
//         uint scoresBalBefore = cScores.balanceOf(address(cScores));

       
//        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             cScores.balanceOf(user1),
//             0,
//             path,
//             to,
//             deadline
//         );


//         // uint member2BalAfter = cScores.balanceOf(cScores.member2());
//         // uint member3BalAfter = cScores.balanceOf(cScores.member3());
//         // uint member4BalAfter = cScores.balanceOf(cScores.member4());
//         // uint member5BalAfter = cScores.balanceOf(cScores.member5());
//         // uint member6BalAfter = cScores.balanceOf(cScores.member6());
//         uint scoresBalAfter = cScores.balanceOf(address(cScores));
        
//         // assertTrue(member2BalAfter > member2BalBefore);
//         // assertTrue(member3BalAfter > member3BalBefore);
//         // assertTrue(member4BalAfter > member4BalBefore);
//         // assertTrue(member5BalAfter > member5BalBefore);
//         // assertTrue(member6BalAfter > member6BalBefore);
//         assertTrue(scoresBalAfter > scoresBalBefore);
     
//         console.log("Scores balance after 1st: ", scoresBalBefore);
//         console.log("Scores balance after 2nd: ", scoresBalAfter);
 

//         /**
//         * AutoSwap won't execute on the first trade into the contract because
//         * the check is done at the start of the function with a zero balance. 
//         * This means that the contract won't autoSwap the taxes from the first trade,
//         * but it will autoSwap the taxes from the second trade. The balance is left higher
//         * because when autoSwapping the contract will take tax from it's own
//         * swap after the second trade so adding a from != address(this) check 
//         * would prevent this.
//         */
//     }

//     function test_ExcludedFromFees() external {
//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);

//         address to = payable(team0);
//         uint deadline = block.timestamp + 1000000000;
//         uint cScoresOwnBalBefore = cScores.balanceOf(address(cScores));

//         (bool feesExclude, bool canDoPreT) = cScores.isExcludedFromRestrictions(team0);

//         assertEq(feesExclude, true);
//         assertEq(canDoPreT, true);

//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             cScores.balanceOf(team0) / 2,
//             0,
//             path,
//             to,
//             deadline
//         );

//          uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             cScores.balanceOf(team0),
//             0,
//             path,
//             to,
//             deadline
//         );

//         uint cScoresOwnBalAfter = cScores.balanceOf(address(cScores));

//         uint balAfterTrade = cScores.balanceOf(team0);

//         assertEq(balAfterTrade, 0);
//         assertEq(cScoresOwnBalAfter, cScoresOwnBalBefore);
//     }


//     function test_ManualSendToTreasury() external {
//         address[] memory path = new address[](2);
//         path[0] = address(cScores);
//         path[1] = address(WETH);
//         cScores.transfer(user1, cScores.balanceOf(team0));
//         vm.stopPrank();
//         vm.startPrank(user1);
//         cScores.approve(address(uniswapV2Router), type(uint).max);

//         address to = payable(user1);
//         uint deadline = block.timestamp + 1000000000;

//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             cScores.balanceOf(user1) / 2,
//             0,
//             path,
//             to,
//             deadline
//         );

//         vm.stopPrank();

//         uint cScoresOwnBalBefore = cScores.balanceOf(address(cScores));
//         vm.prank(team0);
//         cScores.manualSendToTreasury();
//         uint cScoresOwnBalAfter = cScores.balanceOf(address(cScores));

//         uint treasuryBal = cScores.balanceOf(address(cTreasury));

//         assertEq(cScoresOwnBalAfter, 0);
//         assertEq(treasuryBal, cScoresOwnBalBefore);
//     }

//     function test_WithdrawEth() external {
//         vm.deal(address(cScores), 50 ether);

//         assertEq(address(cScores).balance, 50 ether);

//         uint ownerBalBefore = cScores.owner().balance;
//         // Owner has 150 ether, deposits 50 into WETH and 50 into LP so has 50 left
//         assertEq(ownerBalBefore, 50 ether);

//         cScores.withdrawETH();

//         uint ownerBalAfter = cScores.owner().balance;
//         // Owner has 100 ether including 50 from initSetup.Setup()
//         assertEq(ownerBalAfter, 100 ether);

//         assertEq(address(cScores).balance, 0);
//     }

//     function test_ChangeTreasuryWallet() external {
//         address tAddr = address(cTreasury);

//         assertEq(cScores.currentTreasury(), tAddr);

//         cScores.changeTreasuryAddress(user1);

//         assertEq(cScores.currentTreasury(), user1);
//         assertTrue(cScores.currentTreasury() != tAddr);
//     }

    


// }
