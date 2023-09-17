import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract TreasuryBasicTest is InitSetup {
    
    function setUp() override public {
        super.setUp();
        // team0 has 50ETH 
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }

    function test_cTreasuryState() external {
        assertEq(cTreasury.owner(), team0);
        assertEq(cTreasury.receiver(), address(cTreasury));
        assertEq(cTreasury.scoreToken(), address(cScores));
        assertEq(cTreasury.NFTContract(), address(cWagerPass));
        assertEq(cTreasury.routerAddress(), address(uniswapV2Router));
        assertEq(cTreasury.teamShare(), 60);
        assertEq(cTreasury.totalInfluencersPaid(), 0);
        assertEq(cTreasury.totalEthSpentForMarketing(), 0);
        assertEq(cTreasury.totalScoreSpentForMarketing(), 0);
        assertEq(cTreasury.totalTeamScorePaid(), 0);
        assertEq(cTreasury.totalTeamETHPaid(), 0);
        assertEq(cTreasury.teamMembers(0), team0);
        assertEq(cTreasury.teamMembers(1), 0xe1667eF272eA6A984B76403A99da8CB04BEd6370);
        assertEq(cTreasury.teamMembers(2), 0xe8f6aBa2cA583f9D337b66de0A2dE5566935C2e5);
        assertEq(cTreasury.teamMembers(3), 0xc2B36f2948153B31e9f0d36c24DCe987b6Df8630);
        assertEq(cTreasury.teamMembers(4), 0x48cb0Dd6450Ff2aCE0DaC177807082fD7bA252Fc);
        assertEq(cTreasury.teamMembers(5), 0x4842F50FaFE1A628aF24ADe359807eC2AE27E11f);
        assertEq(cTreasury.checkTokenBalances(address(cScores)), cScores.balanceOf(address(cTreasury)));
    }

    function test_cTreasury_NoAuth() external {
        vm.startPrank(user1);
        vm.deal(address(cTreasury), 100 ether);

        vm.expectRevert();
        cTreasury.addAdministrator(user1, true);

        vm.expectRevert();
        cTreasury.setScoreContract(address(this));

        vm.expectRevert();
        cTreasury.setNftContract(address(this));

        vm.expectRevert();
        cTreasury.setSwapReceiver(user0);

        vm.expectRevert();
        cTreasury.changeSwapRouterAddress(user0); 

        vm.expectRevert();
        cTreasury.addTeamMember(user0);

        vm.expectRevert();
        cTreasury.removeTeamMember(user0);

        vm.expectRevert();
        cTreasury._swapScoreTokensForEth(50);

        vm.expectRevert();
        cTreasury.swapAnyTokenForEth(address(cScores), 50);

        vm.expectRevert();
        cTreasury.withdrawETH();

        vm.expectRevert();
        cTreasury.withdrawScoreToken();

        vm.expectRevert();
        cTreasury.withdrawAnyToken(address(cScores));

        vm.expectRevert();
        cTreasury.payToMarketingPartnerWithETH('lol', user0, 1);

        vm.expectRevert();
        cTreasury.payToMarketingPartnerWithScore('lol', user0, 1);
        }

    function test_cTreasury_WAuth() external {
        vm.startPrank(team0);
        cScores.transfer(address(cTreasury), 1000 * 1e9);
        vm.deal(address(cTreasury), 100 ether);

        cTreasury.addAdministrator(user0, true);

        cTreasury.addTeamMember(user0);

        cTreasury.removeTeamMember(user0);

        cScores.transfer(address(cTreasury), 1000 * 1e9);

        cScores.launch();

        cTreasury._swapScoreTokensForEth(50);

        cTreasury.swapAnyTokenForEth(address(cScores), 50);

        cTreasury.withdrawETH();

        cScores.transfer(address(cTreasury), 1000 * 1e9);
        cTreasury.withdrawScoreToken();

        cScores.transfer(address(cTreasury), 1000 * 1e9);
        cTreasury.withdrawAnyToken(address(cScores));

        vm.deal(address(cTreasury), 100 ether);
        cTreasury.payToMarketingPartnerWithETH('lol', user0, 1);

        cScores.transfer(address(cTreasury), 1000 * 1e9);
        cTreasury.payToMarketingPartnerWithScore('lol', user0, 1);

        cTreasury.setScoreContract(address(this));

        cTreasury.setNftContract(address(this));

        cTreasury.setSwapReceiver(address(this));

        cTreasury.changeSwapRouterAddress(address(this));

        assertEq(cTreasury.scoreToken(), address(this));
        assertEq(cTreasury.NFTContract(), address(this));
        assertEq(cTreasury.routerAddress(), address(this));
        assertEq(cTreasury.receiver(), address(this));
        assertEq(cTreasury.isAdministrator(team0), true);
        assertEq(cTreasury.totalTeamMembers(), 6);
        
        vm.stopPrank();
    }
}

contract TreasuryDeepTest is InitSetup {
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



    /////////// Tests ///////////

    function test_cTreasury_NFTFees() external {
        vm.startPrank(user0);
        uint balBefore0 = cTreasury.teamMembers(0).balance;
        uint balBefore1 = cTreasury.teamMembers(1).balance;
        uint balBefore2 = cTreasury.teamMembers(2).balance;
        uint balBefore3 = cTreasury.teamMembers(3).balance;
        uint balBefore4 = cTreasury.teamMembers(4).balance;
        uint balBefore5 = cTreasury.teamMembers(5).balance;

        for(uint i = 0; i < 10; i++) {
            cWagerPass.safeMint{value: 0.1 ether}(user0);
        }
        vm.stopPrank();

        uint teamCoins = address(cTreasury).balance * 60 / 100;
        uint memberShare = teamCoins / 6;
        cTreasury.distributeETHfeeTokens();
        assertEq(cTreasury.totalTeamETHPaid(), teamCoins);

        assertEq(cTreasury.teamMembers(0).balance, balBefore0 + memberShare);
        assertEq(cTreasury.teamMembers(1).balance, balBefore1 + memberShare);
        assertEq(cTreasury.teamMembers(2).balance, balBefore2 + memberShare);
        assertEq(cTreasury.teamMembers(3).balance, balBefore3 + memberShare);
        assertEq(cTreasury.teamMembers(4).balance, balBefore4 + memberShare);
        assertEq(cTreasury.teamMembers(5).balance, balBefore5 + memberShare);

        assertGt(cTreasury.teamMembers(0).balance, balBefore0);
        assertGt(cTreasury.teamMembers(1).balance, balBefore1);
        assertGt(cTreasury.teamMembers(2).balance, balBefore2);
        assertGt(cTreasury.teamMembers(3).balance, balBefore3);
        assertGt(cTreasury.teamMembers(4).balance, balBefore4);
        assertGt(cTreasury.teamMembers(5).balance, balBefore5);

        assertTrue(cTreasury.teamMembers(0).balance == balBefore0 + memberShare);
        assertTrue(cTreasury.teamMembers(1).balance == balBefore1 + memberShare);
        assertTrue(cTreasury.teamMembers(2).balance == balBefore2 + memberShare);
        assertTrue(cTreasury.teamMembers(3).balance == balBefore3 + memberShare);
        assertTrue(cTreasury.teamMembers(4).balance == balBefore4 + memberShare);
        assertTrue(cTreasury.teamMembers(5).balance == balBefore5 + memberShare);

    }

    function test_cTreasury_FeeTokensDistro() external {
        vm.startPrank(user0);

        uint balBefore0 = cScores.balanceOf(address(cTreasury));
        uint balBefore1 = cScores.balanceOf(cTreasury.teamMembers(0));
        uint balBefore2 = cScores.balanceOf(cTreasury.teamMembers(1));
        uint balBefore3 = cScores.balanceOf(cTreasury.teamMembers(2));
        uint balBefore4 = cScores.balanceOf(cTreasury.teamMembers(3));
        uint balBefore5 = cScores.balanceOf(cTreasury.teamMembers(4));
        uint balBefore6 = cScores.balanceOf(cTreasury.teamMembers(5));

        spawnTradingActivity();

        uint teamCoins = cScores.balanceOf(address(cTreasury)) * 60 / 100;

        cTreasury.distributeFeeTokens();

        assertEq(cTreasury.totalTeamScorePaid(), teamCoins);

        uint memberShare = teamCoins / 6;

        assertEq(cScores.balanceOf(cTreasury.teamMembers(0)), balBefore1 + memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(1)), balBefore2 + memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(2)), balBefore3 + memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(3)), balBefore4 + memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(4)), balBefore5 + memberShare);
        assertEq(cScores.balanceOf(cTreasury.teamMembers(5)), balBefore6 + memberShare);

        assertGt(cScores.balanceOf(cTreasury.teamMembers(0)), balBefore1);
        assertGt(cScores.balanceOf(cTreasury.teamMembers(1)), balBefore2);
        assertGt(cScores.balanceOf(cTreasury.teamMembers(2)), balBefore3);
        assertGt(cScores.balanceOf(cTreasury.teamMembers(3)), balBefore4);
        assertGt(cScores.balanceOf(cTreasury.teamMembers(4)), balBefore5);
        assertGt(cScores.balanceOf(cTreasury.teamMembers(5)), balBefore6);
    }
        /////////// Helpers ///////////

    function tokensForEth(
        address[] memory path,
        uint amount,
        address receiver
    ) public {
        cScores.approve(address(uniswapV2Router), amount);
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
        cScores.transfer(address(cScores), 500_000 * 1e9);
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

}