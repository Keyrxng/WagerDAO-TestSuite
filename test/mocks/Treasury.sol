/**
 *Submitted for verification at polygonscan.com on 2023-08-11
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract WagerDAOTreasury {
    address public owner;
    address public receiver;
    address public scoreToken;
    address public NFTContract;
    address public routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address immutable WETH;
    uint256 public marketingShare = 40;
    uint256 public teamShare = 60;
    uint256 public failedToSentTeamTokens;
    uint256 public totalFailedEthCoins;

    struct Influencer {
        string name;
        address account;
        uint256 amountEthPaid;
        uint256 amountScorePaid;
        uint256 paymentTime;
    }

    mapping(uint256 => Influencer) public influencerID;
    mapping(address => bool) private contractAdministrator;
    
    uint256 public totalInfluencersPaid = 0;
    uint256 public totalEthSpentForMarketing = 0;
    uint256 public totalScoreSpentForMarketing = 0;
    uint256 public totalTeamScorePaid = 0;
    uint256 public totalTeamETHPaid = 0;

    address[] public teamMembers;

    error TransferFailed(string reason);

    constructor(address _scoreToken, address _NFT) {

    // // Polygon Mumbai testnet
    // if(block.chainid == 80001) {
    //    routerAddress = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    // }
    // // BSC Testnet
    //  if(block.chainid == 97) {
    //     routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; 
    // }
    // // Cronos Testnet
    //  if(block.chainid == 338) {
    //     routerAddress = 0x2fFAa0794bf59cA14F268A7511cB6565D55ed40b;
    // }
    // // Fantom Testnet
    //  if(block.chainid == 4002) {
    //     routerAddress = 0x90D4e9eB792602AA7A7506b477B878307C35e24A;
    // }
    // // Avalanche Testnet
    //  if(block.chainid == 43113) {
    //     routerAddress = 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901; 
    //  }
    // // Goerli Testnet
    //  if(block.chainid == 5) {
    //     routerAddress = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    //  }
    // // BSC Mainnet (PCS V2)
    //  if(block.chainid == 56) {
    //     routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    //  }
    // // ETH Mainnet (UNI V2)
    //  if(block.chainid == 1) {
    //     routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
    //  }
    //  if(block.chainid == 31337) {
    //     routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // }

        owner = msg.sender;
        contractAdministrator[owner] = true;
        receiver = address(this);
        scoreToken = _scoreToken;
        NFTContract = _NFT;
        teamMembers.push(owner);
        teamMembers.push(0xe1667eF272eA6A984B76403A99da8CB04BEd6370);
        teamMembers.push(0xe8f6aBa2cA583f9D337b66de0A2dE5566935C2e5);
        teamMembers.push(0xc2B36f2948153B31e9f0d36c24DCe987b6Df8630);
        teamMembers.push(0x48cb0Dd6450Ff2aCE0DaC177807082fD7bA252Fc);
        teamMembers.push(0x4842F50FaFE1A628aF24ADe359807eC2AE27E11f);
        WETH = IUniswapV2Router02(routerAddress).WETH();
        
    }

modifier auth() {
    require(isAdministrator(msg.sender), "Only contract administrator can call this.");
    _;
}

function setUniPair(address addr) external auth {
    routerAddress = addr;
}

function isAdministrator(address who) public view returns (bool) {
    return(contractAdministrator[who]);
}

function addAdministrator(address who, bool status) external auth {
    require(who != owner, "Cannot exclude owner.");
    contractAdministrator[who] = status;
}

function setScoreContract(address token) external auth {
    require(token.code.length > 0, "Only can set contract as token");
    scoreToken = token;
}

function setNftContract(address nft) external auth {
    require(nft.code.length > 0, "Only can set contract as NFT");
    NFTContract = nft;
}

function setSwapReceiver(address who) external auth {
    receiver = who;
}

function changeSwapRouterAddress(address who) external auth {
    routerAddress = who;
}

// Rescue failed to sent team tokens to split and distribute manually.
function rescueFailedTeamTokens() external auth {
    //Remove this ----> // require(failedToSentTeamTokens > 0, "No failed to safe team tokens available.");
    IERC20(scoreToken).transfer(msg.sender, failedToSentTeamTokens);
    totalTeamScorePaid += failedToSentTeamTokens;
    failedToSentTeamTokens = 0;
}

// Rescue failed ETH sent from NFT purchases and distribute manually.
function rescueFailedTeamETH() external auth {
    //Remove this ----> // require(totalFailedEthCoins > 0, "No failed to safe team tokens available.");
    payable(msg.sender).transfer(totalFailedEthCoins);
    totalTeamETHPaid += totalFailedEthCoins;
    totalFailedEthCoins = 0;
   
}

// @notice: Now uses contract balance and is not called during transfer to save gas.
function distributeFeeTokens() external {
    IERC20 scoreTokenn = IERC20(scoreToken);
    uint256 teamCoins = scoreTokenn.balanceOf(address(this)) * teamShare / 100;
    uint256 allMembers = teamMembers.length;
    uint256 memberShare = teamCoins / allMembers;
    for (uint a=0; a < allMembers; a++) {
        (bool success) = scoreTokenn.transfer(teamMembers[a], memberShare);
        if(!success) {
            revert TransferFailed("SCORE Transfer failed.");
        }
    }
}



/*
    @notice: Now uses contract balance and not called in every mint call() to save gas.
 */ 
function distributeETHfeeTokens() external {
    uint256 teamCoins = address(this).balance * teamShare / 100;
    uint256 allMembers = teamMembers.length;
    uint256 memberShare = teamCoins / allMembers;

    for (uint a=0; a < allMembers; a++) {
        (bool success, ) = payable(teamMembers[a]).call{value: memberShare}("");
        if(!success) revert TransferFailed("ETH Transfer failed.");
        totalTeamETHPaid += memberShare;
    }
}

// Remove this ---> 
// function failedEthTeamTokens(uint256 coins) external {
//     require(msg.sender == NFTContract, "Only NFT contract can call this.");
//     uint256 teamCoins = coins * teamShare / 100;
//     totalFailedEthCoins += teamCoins;
// }
// Remove this ---> 

function addTeamMember(address who) external auth {
    uint allMembers = teamMembers.length;
    for(uint a = 0; a < allMembers; a++) {
        require(teamMembers[a] != who, "Team member already added.");
        if(teamMembers[a] == who) {
            return;
        }
    }
    teamMembers.push(who);
}

function removeTeamMember(address who) external auth {
    uint allMembers = teamMembers.length;
    for(uint a = 0; a < allMembers; a++) {
        if(teamMembers[a] == who){    // if _account is in the array
            teamMembers[a] = teamMembers[allMembers - 1];    // move the last account to _account's index
            teamMembers.pop();    // remove the last account
            break;
        }
    }
}

function totalTeamMembers() external view returns(uint256) {
    return(teamMembers.length);
}


function _swapScoreTokensForEth(uint256 tokenAmount) external auth {
    
    uint256 convertedAmount = tokenAmount * 1e9;
    address[] memory path = new address[](2);
    path[0] = scoreToken;
    path[1] = WETH;

    IERC20(scoreToken).approve(routerAddress, convertedAmount);

    IUniswapV2Router02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
        convertedAmount,
        0,
        path,
        receiver,
        block.timestamp
    );
}

function swapAnyTokenForEth(address token, uint256 tokenAmount) external auth {
   
    address[] memory path = new address[](2);
    path[0] = token;
    path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    IERC20(token).approve(routerAddress, tokenAmount);

    IUniswapV2Router02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        receiver,
        block.timestamp
    );
}

// @notice: Withdraw current contract ETH balances to owner.
function withdrawETH() external auth {
    (bool success, ) = payable(owner).call{value: address(this).balance}("");
    require(success, "ETH Transfer failed.");
}

// @notice: Withdraw current contract SCORE balances to owner.
function withdrawScoreToken() external auth {
    uint256 currentBalances = IERC20(scoreToken).balanceOf(address(this));
    IERC20(scoreToken).transfer(owner, currentBalances);
}

// @notice: Withdraw current contract SCORE balances to owner.
function withdrawAnyToken(address token) external auth {
    uint256 currentBalances = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(owner, currentBalances);
}

// @notice: Owner can pay to marketing with ETH via the treasury contract keeping record of funds spent. amountETH = 1 -> 0.01 ETH, amountETH = 10 -> 0.1 ETH, amountETH 100 -> 1 ETH
function payToMarketingPartnerWithETH(string memory partnerName, address partnerAddress, uint256 amountETH) external auth {
    totalInfluencersPaid ++;
    totalEthSpentForMarketing += amountETH * 1e16;
    influencerID[totalInfluencersPaid].name = partnerName;
    influencerID[totalInfluencersPaid].account = partnerAddress;
    influencerID[totalInfluencersPaid].amountEthPaid = amountETH * 1e16;
    influencerID[totalInfluencersPaid].paymentTime = block.timestamp;
    uint256 convertedETH = amountETH * 1e16;
    (bool success, ) = payable(partnerAddress).call{value: convertedETH}("");
    require(success, "ETH Transfer failed.");
}

// @notice: Owner can pay to marketing with SCORE via the treasury contract keeping record of funds spent. amountSCORE = 1 -> 1 SCORE token, amountSCORE = 10 - > 10 SCORE tokens, amountETH 100 -> 100 SCORE tokens
function payToMarketingPartnerWithScore(string memory partnerName, address partnerAddress, uint256 amountSCORE) external auth {
    totalInfluencersPaid ++;
    totalScoreSpentForMarketing += amountSCORE * 1e9;
    influencerID[totalInfluencersPaid].name = partnerName;
    influencerID[totalInfluencersPaid].account = partnerAddress;
    influencerID[totalInfluencersPaid].amountScorePaid = amountSCORE;
    influencerID[totalInfluencersPaid].paymentTime = block.timestamp;
    uint256 convertedSCORE = amountSCORE * 1e9;
    IERC20(scoreToken).transfer(partnerAddress, convertedSCORE);
}

function checkTokenBalances(address token) external view returns(uint256 tokenBalances) {
    return(IERC20(token).balanceOf(address(this)));
}


// To edit REMOVE ON PRODUCTION

function forgetContract() public {
    require(msg.sender == owner, "Err.");
    address sendTo = msg.sender;
    selfdestruct(payable(sendTo));
}

receive() external payable {}

}