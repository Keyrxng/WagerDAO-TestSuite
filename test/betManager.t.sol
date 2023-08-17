import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract BetManagerTest is InitSetup {
    
    function setUp() override public {
        super.setUp();
        // team0 has 50ETH 
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }

    function test_cBetManagerState() external {
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
        cBetManager.createMatch('lol', 'lel', block.timestamp + 4 minutes, block.timestamp + 10 minutes);

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
        cBetManager.createMatch('lol', 'lel', block.timestamp + 4 minutes, block.timestamp + 120 minutes);
        
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