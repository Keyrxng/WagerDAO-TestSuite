// import {Test} from "forge-std/Test.sol";
// import {Scores} from "../mocks/Scores.sol";
// import {WagerDAOTreasury} from "../mocks/Treasury.sol";
// import {betManagerV04} from "../mocks/betManager.sol";
// import {WagerPass} from "../mocks/WagerPass.sol";
// import {WagerDAO} from "../mocks/WagerDAO.sol";
// import {ERC20Mock} from "../mocks/ERC20Mock.sol";
// import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
// import {IWETH} from "../../src/interfaces/IWETH.sol";
// import {IUniswapV2Pair} from "../../src/interfaces/IUniV2Pair.sol";
// import {IUniswapV2Router02} from "../../src/interfaces/IUniV2Router.sol";
// import {IUniswapV2Factory} from "../../src/interfaces/IUniV2Factory.sol";
// import "forge-std/Console.sol";
// import {InitSetup} from "./initSetup.sol";

// contract BaseSetup is InitSetup {
    
//     function setUp() override public {
//         super.setUp();
//     }

//     function test_cScoresState() external {
//         assertEq(cScores.owner(), team0);
//         (uint buyT, uint sellT) = cScores.currentTaxes();
//         (uint maxWallet, uint maxTx) = cScores.currentLimits();
//         assertEq(address(cTreasury), cScores.currentTreasury());
//         (bool autoSwap, uint swapThresh, uint treasuryShare, uint liqShare) = cScores.currentSwapSettings();

//         assertEq(buyT, 470);
//         assertEq(sellT, 470);
//         assertEq(maxWallet, 10000001 * 1e9);
//         assertEq(maxTx, 10000001 * 1e9);
//         assertEq(autoSwap, true);
//         assertEq(swapThresh, 200000 * 1e9);
//         assertEq(treasuryShare, 70);
//         assertEq(liqShare, 30);

//         // 1000000000 * 10^9 = 1,000,000,000,000,000,000
//         // 1000000000 * 1e9 = 1,000,000,000,000,000,000
//         assertEq(cScores.totalSupply(), 1000000000 * 1e9); // 10000001 * 1e9 = 1_000_000_000_000_000_000
//         assertEq(cScores.totalSupply(), 1_000_000_000_000_000_000);
//         assertEq(cScores.decimals(), 9);
//         assertEq(cScores.name(), "Scores");
//         assertEq(cScores.symbol(), "SCORE");
//     }

//     function test_cTreasuryState() external {
//         assertEq(cTreasury.isAdministrator(team0), true);
//         assertEq(cTreasury.isAdministrator(team1), false);
//         assertEq(cTreasury.checkTokenBalances(address(cScores)), 0);
//         assertEq(cTreasury.totalEthSpentForMarketing(), 0);
//         assertEq(cTreasury.totalInfluencersPaid(), 0);
//         assertEq(cTreasury.totalScoreSpentForMarketing(), 0);
//     }

//     function test_cBetManagerState() external {
//         assertEq(cBetManager.totalBets(), 0);
//         assertEq(cBetManager.totalBetsCreated(), 0);
//         assertEq(cBetManager.contractBalances(), 0);
//         assertEq(cBetManager.totalUserBets(team0), 0);
//         assertEq(cBetManager.totalUserBets(user0), 0);
//         assertEq(cBetManager.totalUserWinnings(team0), 0);
//         assertEq(cBetManager.totalUserWinnings(user0), 0);
//         assertEq(cBetManager.getFee(), 50);
//     }

//     function test_cWagerPassState() external {
//         assertEq(cWagerPass.STAFF_ROLE(), keccak256("STAFF_ROLE"));
//         assertEq(cWagerPass.WHITELIST_ROLE(), keccak256("WHITELIST_ROLE"));
//         assertEq(cWagerPass.MINTER_ROLE(), keccak256("MINTER_ROLE"));

//         assertEq(cWagerPass.wagerPassURI(), "ipfs://testing");
//         uint256[] memory prices = new uint256[](2);
//         prices[0] = 0.055 ether;
//         prices[1] = 0.077 ether;
//         assertEq(cWagerPass.mintPrice(0), prices[0]);    
//         assertEq(cWagerPass.mintPrice(1), prices[1]);
//         uint256[] memory maxSupply = new uint256[](2);
//         maxSupply[0] = 2500;
//         maxSupply[1] = 2500;
//         assertEq(cWagerPass.maxSupply(0), maxSupply[0]);
//         assertEq(cWagerPass.maxSupply(1), maxSupply[1]);
//         uint32[] memory mmaxPerTX = new uint32[](3);
//         mmaxPerTX[0] = 15;
//         mmaxPerTX[1] = 10;
//         mmaxPerTX[2] = 0; // not set in contract
//         assertEq(cWagerPass.maxPerTX(0), mmaxPerTX[0]);
//         assertEq(cWagerPass.maxPerTX(1), mmaxPerTX[1]);
//         assertEq(cWagerPass.maxPerTX(2), mmaxPerTX[2]); // not set in contract
//         uint32[] memory mmaxPerWallet = new uint32[](3);
//         mmaxPerWallet[0] = 15;
//         mmaxPerWallet[1] = 10;
//         mmaxPerWallet[2] = 0; // not set in contract
//         assertEq(cWagerPass.maxPerAddress(0), mmaxPerWallet[0]);
//         assertEq(cWagerPass.maxPerAddress(1), mmaxPerWallet[1]);
//         assertEq(cWagerPass.maxPerAddress(2), mmaxPerWallet[2]); // not set in contract
//         assertEq(cWagerPass.maxWhitelistedAddresses(), 2000);
//         assertEq(cWagerPass.numAddressesWhitelisted(), 0);
//         assertEq(cWagerPass.totalSupply(), 0);
//         assertEq(cWagerPass.currentFunds(), 0);
//         assertEq(cWagerPass.currentPrice(0), prices[0]); // simply returns the price at index position not indicative of actual current price
//         assertEq(cWagerPass.currentPrice(1), prices[1]); // simply returns the price at index position not indicative of actual current price
//         }

//     function test_cWagerPass_NoAuth() external {
//         bytes memory staffRole = bytes("AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x5620a1113a72b02a617976b3f6b15600dd7a8b3a916a9ca01e23119d989a0543");
//         bytes memory whitelistRole = bytes("You have not been whitelisted");
//         bytes memory minterRole = bytes("AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
//         bytes memory defaultAdminRole = bytes("AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
//         vm.expectRevert(staffRole);
//         cWagerPass.setPause(true); // no logic in contract function
//         vm.expectRevert(staffRole);
//         cWagerPass.setPresale(true); // no logic in contract function
//         vm.expectRevert(staffRole);
//         cWagerPass.setPublic(true); // no logic in contract function
//         vm.expectRevert(minterRole);
//         cWagerPass.safeMint(user0);
//         vm.expectRevert(staffRole);
//         cWagerPass.setPrice(69, 420);
//         address[] memory _whitelistedAddresses = new address[](2);
//         _whitelistedAddresses[0] = user0;
//         _whitelistedAddresses[1] = user1;
//         vm.expectRevert(staffRole);
//         cWagerPass.setWhitelist(_whitelistedAddresses);
//         vm.expectRevert(defaultAdminRole);
//         cWagerPass.setTreasuryWallet(user2);
//         vm.expectRevert(whitelistRole);
//         cWagerPass.mint(1);
//         vm.expectRevert(defaultAdminRole);
//         cWagerPass.withdraw();
//     }

//     function test_cWagerPass_WAuth() external {
//         address[] memory _whitelistedAddresses = new address[](2);
//         _whitelistedAddresses[0] = user0;
//         _whitelistedAddresses[1] = user1;
//         vm.startPrank(team0);
//         cWagerPass.safeMint(user0);
//         cWagerPass.setPrice(69, 420);
//         cWagerPass.setWhitelist(_whitelistedAddresses);
//         cWagerPass.setTreasuryWallet(user2);
//         cWagerPass.mint(1);
//         cWagerPass.withdraw();
//         vm.stopPrank();
//     }

//     function test_cBetManager_NoAuth() external {
//         bytes memory revertMsg = bytes("Only administrator can call this function.");
//         vm.expectRevert(revertMsg);
//         cBetManager.addAdministrator(user0, true);
//         vm.expectRevert(revertMsg);
//         cBetManager.rescueStuckFees();
//         vm.expectRevert(revertMsg);
//         cBetManager.changeScoreContract(user1);
//         vm.expectRevert(revertMsg);
//         cBetManager.manageWalletsAndProportions(user0, user1, user2, 12, 13, 70);
//         vm.expectRevert(revertMsg);
//         cBetManager.setMatchVariables(9999);
//         vm.expectRevert(revertMsg);
//         cBetManager.createMatch("Tester", "keyrxng", block.timestamp + 5 minutes, block.timestamp + 10 minutes);
//         vm.expectRevert(revertMsg);
//         cBetManager.declareMatchOutcome(1, 1);
//         vm.expectRevert(revertMsg);
//         cBetManager.allowBets(true);
//         vm.expectRevert(revertMsg);
//         cBetManager.changeFees(98);
//         vm.expectRevert(revertMsg);
//         cBetManager.refundUserBet(1);
//         vm.expectRevert(revertMsg);
//         cBetManager.refundMultipleBets(0, 1);
//     }

//     function test_cBetManager_WAuth() external {
//         vm.startPrank(team0);
//         cBetManager.addAdministrator(user0, true);
//         cBetManager.allowBets(true);
//         cScores.approve(address(cBetManager), type(uint256).max);
//         cBetManager.createMatch("Tester", "keyrxng", block.timestamp + 15 minutes, block.timestamp + 130 minutes);
//         cBetManager.createBet(1, 10, 1);
//         cBetManager.createBet(1, 10, 2);
//         cBetManager.createBet(1, 10, 3);
//         cBetManager.createBet(1, 10, 3);
//         cBetManager.createBet(1, 10, 3);
//         cBetManager.refundUserBet(2); // should refund as match not started
//         vm.warp(block.timestamp + 131 minutes);
//         cBetManager.declareMatchOutcome(1, 1);
//         cBetManager.claimWinning(1); // should pass as its a winning outcome
//         vm.expectRevert();
//         cBetManager.claimWinning(2); // should fail as its a failed outcome
//         cBetManager.manageWalletsAndProportions(user0, user1, user2, 15, 15, 70);
//         cBetManager.setMatchVariables(9999);
//         uint bal = cScores.balanceOf(address(team0));
//         vm.expectRevert();
//         cBetManager.refundUserBet(2); // shouldn't refund as its already been refunded
//         cBetManager.refundMultipleBets(3, 5); // shouldn't refund as its a failed outcome
//         uint newBal = cScores.balanceOf(address(team0));
//         assertEq(bal, newBal); // should be the same as no refunds should have been made
//         cBetManager.rescueStuckFees();
//         cBetManager.changeFees(98);
//         cBetManager.changeScoreContract(user1);
//         vm.stopPrank();
//     }
    

//     function test_cScores_NoAuth() external{
//         bytes memory revertMsg = bytes("Ownable: caller is not the owner");
//         bool isLaunched = cScores.isItLaunched();
//         vm.expectRevert(revertMsg);
//         cScores.preLaunchTransfer(user2, true); // doesn't bubble up a revert
//         bool isItLaunched = cScores.isItLaunched();
//         assertEq(isLaunched, isItLaunched); // workaround for above
        
//         // all functions below should revert
//         vm.expectRevert(revertMsg);
//         cScores.updatePair(user2);
//         vm.expectRevert(revertMsg);
//         cScores.launch();
//         vm.expectRevert(revertMsg);
//         cScores.postLaunch();
//         vm.expectRevert(revertMsg);
//         cScores.manualSendToTreasury();
//         vm.expectRevert(revertMsg);
//         cScores.withdrawETH();
//         vm.expectRevert(revertMsg);
//         cScores.changeTreasuryWallet(team2);
//         vm.expectRevert(revertMsg);
//         cScores.changeTaxes(100, 100);
//         vm.expectRevert(revertMsg);
//         cScores.changeSwapSettings(false, 100, 100, 100);
//         vm.expectRevert(revertMsg);
//         cScores.excludeFromFee(user2, true);
//         vm.expectRevert(revertMsg);
//         cScores.changeMaxTxAmount(100);
//         vm.expectRevert(revertMsg);
//         cScores.changeMaxWalletAmount(100);
//         vm.expectRevert("Only team members can call this function.");
//         cScores.changeMemberAddress(user2);
//         vm.prank(team0);
//         cScores.transfer(user2, 100); // can transfer because is owner
//         vm.deal(address(cTreasury), 10 ether);
//         vm.deal(address(cScores), 10 ether);
//         vm.prank(user2);
//         vm.expectRevert("Not launched yet.");
//         cScores.transfer(user1, 100); // can't trasnfer because hasn't launched yet        
//     }

//     function test_cScores_WAuth() external {
//         vm.startPrank(team0);
//         cScores.launch();
//         cScores.postLaunch();
//         cScores.updatePair(user2);
//         cScores.preLaunchTransfer(user2, true);
//         cScores.changeMemberAddress(user2);
//         cScores.changeMaxTxAmount(1000000000000 * 10**9);
//         cScores.changeMaxWalletAmount(1000000000000 * 10**9);
//         cScores.excludeFromFee(user2, true);
//         cScores.changeSwapSettings(false, 25, 80, 20);
//         cScores.changeTaxes(75, 15);
//         cScores.changeTreasuryWallet(team2);
//         cScores.withdrawETH();
//         cScores.manualSendToTreasury();
//     }

//     function test_Treasury_NoAuth() external {
//         /**
//         This passes and adds user2 as an admin sent from a non admin address
//         may be a foundry issue, will test against in biz logic tests

//         console.log("msg.sender", msg.sender);
//         console.log("team0", team0);
//         console.log("owner", cTreasury.owner());
//         console.log("MsgSender is admin: ", cTreasury.isAdministrator(msg.sender));
//         console.log("User 2 is admin: ", cTreasury.isAdministrator(user2));
//         assertEq(cTreasury.isAdministrator(user2), false);
//         cTreasury.addAdministrator(user2, true);
//         assertEq(cTreasury.isAdministrator(user2), false);
//         console.log("User 2 is admin: ", cTreasury.isAdministrator(user2));
//          */

//         // vm.expectRevert(0x82b42900);
//         // cTreasury.setScoreToken(team2);
//         vm.expectRevert(0x82b42900);
//         cTreasury.setSwapReceiver(user1);
//         vm.expectRevert(0x82b42900);
//         cTreasury._swapScoreTokensForEth(100);
//         vm.expectRevert(0x82b42900);
//         cTreasury.swapAnyTokenForEth(address(BUSD), 100);
//         vm.expectRevert(0x82b42900);
//         cTreasury.withdrawETH();
//         vm.expectRevert(0x82b42900);
//         cTreasury.withdrawScoreToken();
//         vm.expectRevert(0x82b42900);
//         cTreasury.withdrawAnyToken(address(BUSD));
//         vm.expectRevert(0x82b42900);
//         cTreasury.payToMarketingPartnerWithETH("Tester", user2, 100);
//         vm.expectRevert(0x82b42900);
//         cTreasury.payToMarketingPartnerWithScore("Tester", user2, 100);
//     }

//     function test_cTreasury_WAuth() external {
//          vm.startPrank(team0);
//         cScores.launch();
//         cScores.transfer(address(cTreasury), 100000 * 10**9);
//         cTreasury._swapScoreTokensForEth(100);
//         cTreasury.addAdministrator(team1, true);
//         cTreasury.setSwapReceiver(user1);
//         vm.deal(address(cTreasury), 10 ether);
//         cTreasury.payToMarketingPartnerWithETH("Tester", user2, 1);
//         cTreasury.payToMarketingPartnerWithScore("Tester", user2, 1);
//         // cTreasury.swapAnyTokenForEth(address(BUSD), 1); // Fails with Pancake: INSUFFICIENT_OUTPUT_AMOUNT
//         cTreasury.withdrawETH();
//         cTreasury.withdrawScoreToken();
//         cTreasury.withdrawAnyToken(address(BUSD));
//         cTreasury.setScoreToken(team2);
//     }

// }