import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract FeeDistroBasicTest is InitSetup {
    
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

contract FeeDistroDeepTest is InitSetup {
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

    /**
        IERC20 public scoreContract;
    NFTInterface public NFTContract;
    address public owner;
    address public betManager;
    uint256 public oneDay = 86400;
    uint256 public threeDays = oneDay * 3;
    uint256 public tokenDecimals = 10 ** 9;
    mapping(uint256 => uint256) public lastTimeRewardsClaimed;
    mapping(address => uint256) public claimedRewards;
    uint256 public availableForDistribution;
    uint256 public totalDistributed;

    constructor(address _tokenAddress, address NFTAddress) {
        scoreContract = IERC20(_tokenAddress);
        owner = msg.sender;
        NFTContract = NFTInterface(NFTAddress);
    }

    function setBetManager(address _betManager) public {
        require(msg.sender == owner, "Err.");
        betManager = _betManager;
    }

    modifier onlyBetManager {
        require(msg.sender == betManager, "Only bet manager can call this.");
        _;
    }

    function syncFees(uint256 addFees) public onlyBetManager {
        availableForDistribution += addFees;
    }

    function rescueTokens() public {
        require(msg.sender == owner, "Err.");
        uint256 availableTokens = scoreContract.balanceOf(address(this));
        try scoreContract.transfer(msg.sender, availableTokens) {
            availableForDistribution = 0;
        } catch {}
    }

    function rewardsInfo() public view returns(uint256 availableRewards, uint256 totalDistributedRewards) {
        availableRewards = availableForDistribution / tokenDecimals;
        totalDistributedRewards = totalDistributed / tokenDecimals;
        return(availableRewards, totalDistributedRewards);
    }

    function eligibility(address who) internal view returns(bool) {
       uint256 nftID = NFTContract.tokenOfOwnerByIndex(who, 0);
       uint256 waitTime = lastTimeRewardsClaimed[nftID] + 3 days;
       if(block.timestamp > waitTime) return true;
       else return false;
    }

    function evaluateUser(address who) internal view returns(bool) {
        uint256 userBalance = checkBalances(who);
        if(userBalance > 0) return true;
        else return false;
    }

    function checkBalances(address who) internal view returns (uint256) {
        uint256 userBalance = NFTContract.balanceOf(who);
        return(userBalance);
    }

    function claimRewards() public {
        address nftOwner = msg.sender;
        require(evaluateUser(nftOwner), "Not NFT holder.");
        require(eligibility(nftOwner), "Already claimed for 3 day period.");
        uint256 divider = NFTContract.totalSupply();
        uint256 onePart = availableForDistribution / divider;
        uint256 nftID = NFTContract.tokenOfOwnerByIndex(nftOwner, 0);

        if(availableForDistribution == 0) return;
        try scoreContract.transfer(nftOwner, onePart) {
            lastTimeRewardsClaimed[nftID] = block.timestamp;
            availableForDistribution -= onePart;
            claimedRewards[nftOwner] += onePart;
            totalDistributed += onePart;
        } catch {}

    } */


}