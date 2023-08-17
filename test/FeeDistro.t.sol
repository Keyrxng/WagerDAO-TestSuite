import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract FeeDistroTest is InitSetup {
    
    function setUp() override public {
        super.setUp();
        // team0 has 50ETH 
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }

    function test_cFeeDistro_State() external {
        assertEq(address(cFeeDistro.scoreContract()), address(cScores));
        assertEq(address(cFeeDistro.NFTContract()), address(cWagerPass));
        assertEq(cFeeDistro.owner(), team0);
        assertEq(cFeeDistro.betManager(), address(cBetManager));
        assertEq(cFeeDistro.oneDay(), 86400);
        assertEq(cFeeDistro.threeDays(), 86400 * 3);
        assertEq(cFeeDistro.tokenDecimals(), 10 ** 9);
        assertEq(cFeeDistro.availableForDistribution(), 0);
        assertEq(cFeeDistro.totalDistributed(), 0);
    }

    function test_cFeeDistro_NoAuth() external {
        vm.startPrank(user0);

        vm.expectRevert();
        cFeeDistro.syncFees(69420);

        assertEq(cFeeDistro.availableForDistribution(), 0);

        vm.stopPrank();
    }

    function test_cFeeDistro_WAuth() external {
        vm.prank(address(cBetManager));

        cFeeDistro.syncFees(69420);

        assertEq(cFeeDistro.availableForDistribution(), 69420);
    }





}