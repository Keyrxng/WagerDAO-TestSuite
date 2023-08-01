// SPDX-License-Identifier: UNLICENSED
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
    address private receiver;
    address private scoreToken = 0x2d94126ACFd8F6dAd5811eec15FD019f0E4EBb57;
    address private routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

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

    constructor() {
        owner = msg.sender;
        contractAdministrator[owner] = true;
        receiver = address(this);
    }

    error Unauthorized();

modifier auth() {
    if(msg.sender != owner || !contractAdministrator[msg.sender]) revert Unauthorized();
    _;
}

function isAdministrator(address who) public view returns (bool) {
    return contractAdministrator[who];
}

function addAdministrator(address who, bool status) external auth {
    require(who != owner, "Cannot exclude owner.");
    contractAdministrator[who] = status;
}

function setScoreToken(address token) external auth {
    scoreToken = token;
}

function setSwapReceiver(address who) external auth {
    receiver = who;
}

function _swapScoreTokensForEth(uint256 tokenAmount) external auth {
    
    uint256 convertedAmount = tokenAmount * 1e9;
    address[] memory path = new address[](2);
    path[0] = scoreToken;
    path[1] = IUniswapV2Router02(routerAddress).WETH();

    IERC20(scoreToken).approve(routerAddress, convertedAmount);

    IUniswapV2Router02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
        convertedAmount,
        0,
        path,
        receiver,
        block.timestamp
    );
}

function swapAnyTokenForEth(address token, uint256 tokenAmount) public auth {
   
    address[] memory path = new address[](2);
    path[0] = token;
    path[1] = IUniswapV2Router02(routerAddress).WETH();

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
function withdrawETH() public auth {
    (bool success, ) = payable(owner).call{value: address(this).balance}("");
    require(success, "ETH Transfer failed.");
}

// @notice: Withdraw current contract SCORE balances to owner.
function withdrawScoreToken() public auth {
    uint256 currentBalances = IERC20(scoreToken).balanceOf(address(this));
    IERC20(scoreToken).transfer(owner, currentBalances);
}

// @notice: Withdraw current contract SCORE balances to owner.
function withdrawAnyToken(address token) public auth {
    uint256 currentBalances = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(owner, currentBalances);
}

// @notice: Owner can pay to marketing with ETH via the treasury contract keeping record of funds spent. amountETH = 1 -> 0.01 ETH, amountETH = 10 -> 0.1 ETH, amountETH 100 -> 1 ETH
function payToMarketingPartnerWithETH(string memory partnerName, address partnerAddress, uint256 amountETH) public auth {
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
function payToMarketingPartnerWithScore(string memory partnerName, address partnerAddress, uint256 amountSCORE) public auth {
    totalInfluencersPaid ++;
    totalScoreSpentForMarketing += amountSCORE * 1e9;
    influencerID[totalInfluencersPaid].name = partnerName;
    influencerID[totalInfluencersPaid].account = partnerAddress;
    influencerID[totalInfluencersPaid].amountScorePaid = amountSCORE;
    influencerID[totalInfluencersPaid].paymentTime = block.timestamp;
    uint256 convertedSCORE = amountSCORE * 1e9;
    IERC20(scoreToken).transfer(partnerAddress, convertedSCORE);
}

function checkTokenBalances(address token) public view returns(uint256 tokenBalances) {
    return(IERC20(token).balanceOf(address(this)));
}

receive() external payable {}

// To edit REMOVE ON PRODUCTION



}