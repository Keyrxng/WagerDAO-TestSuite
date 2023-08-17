/**
 *Submitted for verification at polygonscan.com on 2023-08-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface NFTInterface {
     function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
     function balanceOf(address account) external view returns (uint256);
     function totalSupply() external view returns (uint256);
}

contract NFTBetFeesDistributor {

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

    }
}