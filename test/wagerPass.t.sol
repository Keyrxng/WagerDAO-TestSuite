import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract WagerPassTest is InitSetup {
    
    function setUp() override public {
        super.setUp();
        // team0 has 50ETH 
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }


    function test_cWagerPassState() external {
        assertEq(address(cWagerPass.treasury()), address(cTreasury));
        assertEq(cWagerPass.hasRole(cWagerPass.MINTER_ROLE(), team0), true);
        assertEq(cWagerPass.uri(), "WillAssignLater");
        assertEq(cWagerPass.price(), 0.1 ether);
        assertEq(cWagerPass.totalSupply(), 0);
        assertEq(cWagerPass.name(), "Score NFT");
        assertEq(cWagerPass.symbol(), "SNFT");
    }

    function test_cWagerPass_NoAuth() external {
        vm.startPrank(user0);

        vm.expectRevert();
        cWagerPass.updateUri('lol');

        vm.expectRevert();
        cWagerPass.updateMintPrice(999999999999);

        vm.expectRevert();
        cWagerPass.safeMint{value: 0.001 ether}(user0);
    }

    function test_cWagerPass_WAuth() external {
        vm.deal(team0, 999999999999 ether);
        vm.startPrank(team0);

        cWagerPass.updateUri('lol');

        cWagerPass.updateMintPrice(999999999999);

        cWagerPass.safeMint{value: 999999999999 * 1e17}(user0);

        vm.stopPrank();
    }

}