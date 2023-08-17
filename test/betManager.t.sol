import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract BetManagerBasicTest is InitSetup {
    function setUp() public override {
        super.setUp();
        // team0 has 50ETH
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }

    function test_cBetManager_State() external {
        assertEq(address(cBetManager.scoreContract()), address(cScores));
        assertEq(cBetManager._owner(), team0);
        assertEq(cBetManager.bettingAllowed(), false);
        assertEq(cBetManager.totalBets(), 0);
        assertEq(cBetManager.totalBetsCreated(), 0);
        assertEq(cBetManager.withdrawFee(), 50);
        assertEq(cBetManager.nftRewardFee(), 50);
        assertEq(cBetManager.contractBalances(), 0);
        assertEq(cBetManager.oneDay(), 86400);
        assertEq(cBetManager.currentEpoch(), 0);
        assertEq(cBetManager.bettingLaunchedAt(), 0);
        // assertEq(cBetManager.deployer(), team0);
        assertEq(cBetManager.deployer(), address(0));
        assertEq(cBetManager.multiplier(), 10 ** 9);
        assertEq(cBetManager.divider(), 10000);
        assertEq(cBetManager.teamWallet(), team0);
        assertEq(cBetManager.treasuryWallet(), team0);
        assertEq(cBetManager.devWallet(), team0);
        assertEq(address(cBetManager.nftFeeDistributor()), address(cFeeDistro));
        assertEq(cBetManager.feesToTeam(), 20);
        assertEq(cBetManager.feesToTreasury(), 30);
        assertEq(cBetManager.feesToDevelopment(), 50);
        assertEq(cBetManager.timeToDeclareResult(), 1 minutes);
        assertEq(cBetManager.contractFees(), 0);
    }

    function test_cBetManager_NoAuth() external {
        vm.startPrank(user0);

        vm.expectRevert();
        cBetManager.addAdministrator(user0, true);

        vm.expectRevert();
        cBetManager.setNftFeesDistributor(address(this));

        vm.expectRevert();
        cBetManager.rescueStuckFees();

        vm.expectRevert();
        cBetManager.changeScoreContract(address(this));

        vm.expectRevert();
        cBetManager.manageWalletsAndProportions(user0, user0, user0, 5, 5, 90);

        vm.expectRevert();
        cBetManager.setMatchVariables(76);

        vm.expectRevert();
        cBetManager.createMatch(
            "lol",
            "lel",
            block.timestamp + 4 minutes,
            block.timestamp + 10 minutes
        );

        vm.expectRevert();
        cBetManager.declareMatchOutcome(1, 1);

        vm.expectRevert();
        cBetManager.allowBets(false);

        vm.expectRevert();
        cBetManager.changeFees(9, 7);

        vm.expectRevert();
        cBetManager.refundUserBet(1);

        vm.expectRevert();
        cBetManager.refundMultipleBets(1, 5);

        vm.stopPrank();
    }

    function test_cBetManager_WAuth() external {
        vm.startPrank(team0);
        console.log("SCORES BALANCE OF TEAM0: ", cScores.balanceOf(team0));

        cBetManager.addAdministrator(user0, true);

        cBetManager.setNftFeesDistributor(address(this));

        cBetManager.rescueStuckFees();

        cBetManager.manageWalletsAndProportions(user0, user0, user0, 5, 5, 90);

        cBetManager.setMatchVariables(76);
        cBetManager.allowBets(true);
        cScores.approve(address(cBetManager), type(uint).max);

        cScores.launch();
        cBetManager.createMatch(
            "lol",
            "lel",
            block.timestamp + 4 minutes,
            block.timestamp + 120 minutes
        );

        cBetManager.createBet(1, 10, 1);
        cBetManager.createBet(1, 10, 1);
        cBetManager.createBet(1, 10, 1);
        cBetManager.createBet(1, 10, 1);

        cBetManager.refundUserBet(1);
        cBetManager.refundMultipleBets(2, 5);

        vm.roll(block.timestamp + 250 minutes);
        vm.warp(block.timestamp + 250 minutes);

        cBetManager.declareMatchOutcome(1, 2);
        cBetManager.changeFees(9, 7);
        cBetManager.changeScoreContract(address(this));
    }
}

contract BetManagerDeepTest is InitSetup {
    struct userBetDetails {
        address originalBettor;
        uint256 amountOfBet;
        uint256 outcomePrediction;
        uint256 timeOfBet;
        uint256 betMatchId;
        uint256 wonAmount;
        uint256 betNumber;
        bool adminIntervened;
        bool winning;
        bool claimed;
    }

    struct dailyBets {
        string Team1;
        string Team2;
        uint256 matchStart;
        uint256 matchEnd;
        uint256 result;
        bool adminDeclaredResult;
        uint256 pooledTeam1;
        uint256 pooledTeam2;
        uint256 pooledEqual;
        uint256 totalPooledBets;
        uint256 totalClaimed;
    }

    function setUp() public override {
        super.setUp();
        vm.startPrank(team0);
        cScores.launch();
        cScores.transfer(user0, 10_000 * 1e9);
        cScores.transfer(user1, 10_000 * 1e9);
        cScores.transfer(user2, 10_000 * 1e9);
        cScores.transfer(address(cTreasury), 1_000_000 * 1e9);

        vm.deal(address(cTreasury), 5 ether);
        vm.deal(user0, 2 ether);
        vm.deal(user1, 2 ether);
        vm.deal(user2, 2 ether);
        vm.deal(team1, 2 ether);

        cBetManager.createMatch(
            "lol",
            "lel",
             block.timestamp + 4 minutes,
            block.timestamp + 120 minutes
        );

        cBetManager.createMatch("kek", "pepe", block.timestamp + 15 minutes, block.timestamp + 140 minutes);
        cBetManager.createMatch("Key", "Rxng", block.timestamp + 50 minutes, block.timestamp + 180 minutes);
        cBetManager.allowBets(true);
        vm.stopPrank();
   
    }

    function test_cBetManager_DemoRun() external {
        uint user0Balance = cScores.balanceOf(user0);
        uint user1Balance = cScores.balanceOf(user1);
        uint user2Balance = cScores.balanceOf(user2);

        vm.startPrank(user0);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(1, 10, 1); // loser
        cBetManager.createBet(2, 500, 3); // loser
        cBetManager.createBet(3, 1300, 2); // loser
        vm.stopPrank();

        vm.startPrank(user1);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(1, 10, 1); // loser
        cBetManager.createBet(2, 500, 3); // loser
        cBetManager.createBet(3, 1300, 2); // loser
        vm.stopPrank();

        vm.startPrank(user2);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(2, 1300, 2); // loser
        cBetManager.createBet(3, 500, 3); // winner 
        cBetManager.createBet(1, 10, 2); // winner
        vm.stopPrank();

        vm.startPrank(team0);
        vm.roll(block.timestamp + 250 minutes);
        vm.warp(block.timestamp + 250 minutes);

        cBetManager.declareMatchOutcome(1, 2);
        cBetManager.declareMatchOutcome(2, 1);
        cBetManager.declareMatchOutcome(3, 3);

        

        vm.stopPrank();

        vm.startPrank(user0);
        vm.expectRevert();
        cBetManager.claimWinning(1);
        vm.expectRevert();
        cBetManager.claimWinning(2);
        vm.expectRevert();
        cBetManager.claimWinning(3);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert();
        cBetManager.claimWinning(4);
        vm.expectRevert();
        cBetManager.claimWinning(5);
        vm.expectRevert();
        cBetManager.claimWinning(6);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert();
        cBetManager.claimWinning(7);
        cBetManager.claimWinning(8);
        cBetManager.claimWinning(9);

        vm.stopPrank();
        assertLt(cScores.balanceOf(user0), user0Balance);
        assertLt(cScores.balanceOf(user1), user1Balance);
        assertGt(cScores.balanceOf(user2), user2Balance);
    }

    function test_cWagerPass_ClaimWinnings() external {
 
        vm.startPrank(user0);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(1, 10, 1); // winner
        cBetManager.createBet(2, 500, 1); // winner
        cBetManager.createBet(3, 1300, 1); // winner
        vm.stopPrank();

        vm.startPrank(user1);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(1, 10, 1); // winner
        cBetManager.createBet(2, 500, 1); // winner
        cBetManager.createBet(3, 1300, 1); // winner
        vm.stopPrank();

        vm.startPrank(user2);
        cScores.approve(address(cBetManager), type(uint).max);

        cBetManager.createBet(1, 1300, 1); // winner
        cBetManager.createBet(2, 500, 1); // winner
        cBetManager.createBet(3, 10, 1); // winner
        vm.stopPrank();

        vm.startPrank(team0);

        vm.roll(block.timestamp + 250 minutes);
        vm.warp(block.timestamp + 250 minutes);

        cBetManager.declareMatchOutcome(1, 1);
        cBetManager.declareMatchOutcome(2, 1);
        cBetManager.declareMatchOutcome(3, 1);

        vm.stopPrank();

        vm.startPrank(user0);
        cBetManager.claimWinning(1);
        cBetManager.claimWinning(2);
        cBetManager.claimWinning(3);
        vm.stopPrank();

        vm.prank(user1);
        cBetManager.claimWinning(4);

        vm.prank(user2);
        cBetManager.claimWinning(7);

        vm.prank(user1);
        cBetManager.claimWinning(5);

        vm.prank(user2);
        cBetManager.claimWinning(8);

        vm.prank(user1);
        cBetManager.claimWinning(6);

        vm.prank(user2);
        cBetManager.claimWinning(9);

        




    }
}
