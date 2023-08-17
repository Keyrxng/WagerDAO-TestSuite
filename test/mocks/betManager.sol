/**
 *Submitted for verification at polygonscan.com on 2023-08-11
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface IDistributor {
    function syncFees(uint256 addFees) external;
}

contract betManager_V01 {

IERC20 public scoreContract;
address public _owner;
bool public bettingAllowed;
uint256 public totalBets;
uint256 public totalBetsCreated;
uint256 public withdrawFee = 50;
uint256 public nftRewardFee = 50;
uint256 public contractBalances;
uint256 public oneDay = 86400;
uint256 public currentEpoch;
uint256 public bettingLaunchedAt;
address public deployer;
uint256 public multiplier = 10 ** 9;   // To edit according token decimals
uint256 public divider = 10000;

// Set fees distribution
address public teamWallet;
address public treasuryWallet;
address public devWallet;
address public nftFeeDistributor;
uint256 public feesToTeam = 20; // Proportion
uint256 public feesToTreasury = 30; // Proportion
uint256 public feesToDevelopment = 50; // Proportion

uint256 public timeToDeclareResult = 1 minutes;
uint256 public contractFees; // Prevent stuck fee tokens in the contract.

event ErrorReason(string reason);

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
    string  Team1;
    string  Team2;
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

mapping(uint256 => userBetDetails) private userBetID;
mapping(uint256 => dailyBets) private dailyBetsID;

mapping (address => bool) private administrators;

uint256[] private activeBets;

mapping(address => uint256[]) private userBetsIds;
mapping(address => uint256) public totalUserBets;
mapping(address => uint256) public totalUserWinnings;

constructor(address _tokenAddress, address _nftFeeDistributor) {
    scoreContract = IERC20(_tokenAddress);
    _owner = msg.sender;
    teamWallet = msg.sender;
    treasuryWallet = msg.sender;
    devWallet = msg.sender;
    nftFeeDistributor = _nftFeeDistributor;
    administrators[_owner] = true;
}

modifier onlyAdministrator {
    require(administrators[msg.sender], "Only administrator can call this function.");
    _;
}

function addAdministrator(address who, bool state) public onlyAdministrator {
    require(who != _owner, "Cannot exclude contract's owner.");
    administrators[who] = state;
}

function setNftFeesDistributor(address newDistributor) public onlyAdministrator {
    require(newDistributor.code.length > 0, "Can only set contract.");
    nftFeeDistributor = newDistributor;
}

// Public accesible functions

/** @notice Create bet user functionality. matchID = the match number that you want to bet on, betAmount = amount of accepted token that you want to bet with, outcome = result that you bet for (1-team1Win, 2-team2Win, 3-equalResult).*/
function createBet (
    uint256 matchID,
    uint256 betAmount,
    uint256 outcome
) external returns (bool _success) {
    require(bettingAllowed, "No new deposits allowed"); // Check ig betting is paused by contract owner/administrator.
    require(outcome == 1 || outcome == 2 || outcome == 3, "Only 1 2 or 3 accepted for footbal."); // 1 = Team1 win, 2 = Team2 win, 3 = Equal result between teams.
    require(betAmount > 0, "Amount must be above zero.");   // Bet amount should be always greater than zero.
    
    dailyBets storage getAvailability = dailyBetsID[matchID];
    uint256 betsStartAt = getAvailability.matchStart;
    uint256 lastMinutesBuffer = betsStartAt - 1 minutes;   // Bets for match closes 1 minute before match start.
    uint256 currentTime = block.timestamp;

    require(betsStartAt != 0, "Match currently do not exist.");
    require(currentTime <= lastMinutesBuffer, "Bet time for this match expired.");

    // Depositor must approve tokens transfer on behalf of this contract first
    require(scoreContract.transferFrom(msg.sender, address(this), betAmount), "$SCORE tokens transfer failed.");

    if(outcome == 1) {
        dailyBetsID[matchID].pooledTeam1 += betAmount;
    } else if(outcome == 2) {
        dailyBetsID[matchID].pooledTeam2 += betAmount;
    } else if(outcome == 3) {
        dailyBetsID[matchID].pooledEqual += betAmount;
    }

    dailyBetsID[matchID].totalPooledBets += betAmount;

    totalBets++;
    userBetID[totalBets].originalBettor = msg.sender;
    userBetID[totalBets].amountOfBet += betAmount;
    userBetID[totalBets].outcomePrediction = outcome;
    userBetID[totalBets].timeOfBet = block.timestamp;
    userBetID[totalBets].betMatchId = matchID;
    userBetID[totalBets].betNumber = totalBets;
    
    userBetID[totalBets].adminIntervened = false;
    userBetID[totalBets].claimed = false;
    userBetID[totalBets].winning = false;
   
    // Adds bets id corresponding to the current user
    userBetsIds[msg.sender].push(totalBets);
    
    contractBalances += betAmount;
    totalUserBets[msg.sender] += betAmount;

    return true;
}

/** @notice Claim winnings for specific bet ID number. Can be called only from user that created this specific bet and if it is amongst winning bets.*/
function claimWinning(uint256 betID) public {
    require(betID > 0 && betID <= totalBets, "ID out of bounds."); // Check if not existing ID is entered.

    userBetDetails storage betDetails = userBetID[betID];
    dailyBets storage dailyDetails = dailyBetsID[betDetails.betMatchId];

    uint256 totalPooledAmountForThisMatch = dailyDetails.totalPooledBets;
    uint256 pooledForThisOutcome;
    require(msg.sender == betDetails.originalBettor, "This betID belongs to someone else.");    // Check if msg sender is the original bettor for current ID.
    require(dailyDetails.result > 0, "Result not declared by administrator yet."); // Check if result is declared by administrator.

    if(dailyDetails.result == 1) {
        pooledForThisOutcome = dailyDetails.pooledTeam1;
    } else if(dailyDetails.result == 2) {
        pooledForThisOutcome = dailyDetails.pooledTeam2;
    } else if(dailyDetails.result == 3) {
        pooledForThisOutcome = dailyDetails.pooledEqual;
    }

    uint256 calculateUserPoolWeight;
    uint256 userWeightAdjusted;

    uint256 remainderPercent;
    uint256 remainderPercentAdjuted;
    uint256 remainderAmount;
    
    uint256 userPoolSharePercent = ((betDetails.amountOfBet * multiplier) /  pooledForThisOutcome) * 100;
    calculateUserPoolWeight = (totalPooledAmountForThisMatch * (userPoolSharePercent / multiplier)) / 100;

    remainderPercent =  userPoolSharePercent % multiplier;
    remainderPercentAdjuted =  (remainderPercent * 100) / multiplier;
    remainderAmount = (totalPooledAmountForThisMatch * remainderPercentAdjuted) / divider;
    userWeightAdjusted = calculateUserPoolWeight + remainderAmount;

    require(betDetails.outcomePrediction == dailyDetails.result, "Your prediction was not accurate.");   // Check user prediction vs actual result.
    require(!betDetails.claimed, "You have already claimed this bet."); // Check if use have already claimed his rewards.
    require(totalPooledAmountForThisMatch >= dailyDetails.totalClaimed + userWeightAdjusted, "More than the total funds available in this bet pool."); // Prevent extra spending.

     if(contractBalances < userWeightAdjusted) {
        return;
    }

    uint256 fees = (userWeightAdjusted * withdrawFee) / 1000;
    uint256 nftRewards = (userWeightAdjusted * nftRewardFee) / 1000;
    uint256 deductAmount = fees + nftRewards;
    uint256 amountToUser = userWeightAdjusted - deductAmount;

    betDetails.wonAmount = amountToUser;
    betDetails.claimed = true;
    betDetails.winning = true;
    dailyDetails.totalClaimed += userWeightAdjusted;

    uint256 teamShare = (fees * feesToTeam) / 100;
    uint256 treasuryShare = (fees * feesToTreasury) / 100;
    uint256 developmentShare = (fees * feesToDevelopment) / 100;

    if(fees > 0) {
        try scoreContract.transfer(teamWallet, teamShare) {}  // Transfer withdraw fees to team address.
        catch Error(string memory reason) {
            contractFees += teamShare;  // Add fees to separate variable if transfers fail to rescue fee tokens manually.
            emit ErrorReason(reason);
        }

        try  scoreContract.transfer(devWallet, developmentShare) {} // Transfer withdraw fees to development address.
        catch Error(string memory reason) {
            contractFees += developmentShare;  // Add fees to separate variable if transfers fail to rescue fee tokens manually.
            emit ErrorReason(reason);
        }

        try  scoreContract.transfer(treasuryWallet, treasuryShare) {}  // Transfer withdraw fees to treasury address.
        catch Error(string memory reason) {
            contractFees += treasuryShare;  // Add fees to separate variable if transfers fail to rescue fee tokens manually.
            emit ErrorReason(reason);
        }

        // Transfer withdraw fees to NFT rewards distributor and sync balances.
        try  scoreContract.transfer(nftFeeDistributor, nftRewards) {
            IDistributor(nftFeeDistributor).syncFees(nftRewards);
        } 
        catch Error(string memory reason) {
            contractFees += nftRewards;  // Add fees to separate variable if transfers fail to rescue fee tokens manually.
            emit ErrorReason(reason);
        }
    }

    require(scoreContract.transfer(msg.sender, amountToUser), "Claim transfer failed.");

    totalUserWinnings[msg.sender] += amountToUser;
    contractBalances -= userWeightAdjusted;
}



// Read functions

/** @notice Returns current fees deducted on claim winning.*/
function getFee() external view returns (uint256 currentFee) {
    return withdrawFee;
}

/** @notice Returns all created bets for user.*/
function getAllUserBets(address user) public view returns (uint256[] memory) {
    return userBetsIds[user];
}

/** @notice Returns complete details for specific bet that user created.*/
function getBetDetails(uint256 number) external view returns(address Bettor, uint256 BettingAmount,
uint256 BetOutcomePrediction, uint256 BetTime, uint256 betMatch, uint256 winAmount, uint256 betNumb, bool isAdminIntervened, bool isItWin, bool IsItClaimed) {
    userBetDetails memory B = userBetID[number];
    return (B.originalBettor, B.amountOfBet, B.outcomePrediction, B.timeOfBet, B.betMatchId, B.wonAmount, B.betNumber, B.adminIntervened, B.winning, B.claimed);
}

/** @notice Returns complete details for specific match that administrator created.*/
function getMatchFullDetails(uint256 matchNumber) public view returns (string memory team1, string memory team2, uint256 startT,
uint256 endT, uint256 finalResult, bool adminDeclared, uint256 pooledTm1, uint256 pooledTm2, uint256 pooledEql, uint256 pooledTotal, uint256 claimedTotal) {
    dailyBets storage b = dailyBetsID[matchNumber];
    (pooledTm1, pooledTm2, pooledEql, pooledTotal) = getPooledAmounts(matchNumber);
    return(b.Team1, b.Team2, b.matchStart, b.matchEnd, b.result, b.adminDeclaredResult, pooledTm1, pooledTm2, pooledEql, pooledTotal, b.totalClaimed);
}

function getPooledAmounts(uint256 matchNumber) internal view returns (uint256 pooledTm1, uint256 pooledTm2, uint256 pooledEql, uint256 pooledTotal) {
    dailyBets storage b = dailyBetsID[matchNumber];
    return(b.pooledTeam1, b.pooledTeam2, b.pooledEqual, b.totalPooledBets);
}


// Administrators only accessible functions.

/** @notice Rescue stuck token accepted for bets.  (Only Administrators)*/
function rescueStuckFees() public onlyAdministrator {
    uint256 tokensToRescue = contractFees;
    contractFees = 0;
    require(scoreContract.transfer(msg.sender, tokensToRescue), "Transfer failed");
}

/** @notice Sets the token accepted for bets.  (Only Administrators)*/
function changeScoreContract(address newCA) public onlyAdministrator {
    require(newCA.code.length > 0, "Can only set contract.");
    scoreContract = IERC20(newCA);
}

/** @notice Sets fee receiver wallets and proportions.  (Only Administrators)*/
function manageWalletsAndProportions(address newTeamW, address newTreasuryW, address devW,
uint256 percentTreasury, uint256 percentDev, uint256 percentTeam) public onlyAdministrator {
require(percentTreasury + percentDev + percentTeam == 100, "Sum of proportions should be always 100.");

    devWallet = devW;
    teamWallet = newTeamW;
    treasuryWallet = newTreasuryW;

    feesToTeam = percentTeam;
    feesToTreasury = percentTreasury;
    feesToDevelopment = percentDev;
}

/** @notice Sets last minute time before bets closes for match. Convert numbers to minutes. 1 = one minute, 2 = two minutes etc.  (Only Administrators)*/
function setMatchVariables(uint256 newValue) public onlyAdministrator {
    require(newValue >= 1, "Cannot set below 1 minute.");
    uint256 convertToMinutes = newValue * 60;
    timeToDeclareResult = convertToMinutes;
}

/** @notice Creates new match that can be bet on. (Only Administrators)*/
function createMatch (string memory newTeam1, string memory newTeam2, uint256 startTime, uint256 endTime) public onlyAdministrator {
    require(startTime >= block.timestamp + 3 minutes, "Betting should start at least 3 minutes before match.");
   
    require(endTime > startTime, "End match time must be greater than start match time."); // Prevent errors with times inserted.
    // 105 minutes in production
    require(endTime - startTime >= 105 minutes, "Each match should be atleast 105 minutes."); // Prevent errors with times inserted.
    // 180 minutes in production
    require(endTime - startTime <= 180 minutes, "Duration should be less than 180 miutes."); // Prevent errors with times inserted.
    
    totalBetsCreated++;
    dailyBetsID[totalBetsCreated].Team1 = newTeam1;
    dailyBetsID[totalBetsCreated].Team2 = newTeam2;
    dailyBetsID[totalBetsCreated].matchStart = startTime;
    dailyBetsID[totalBetsCreated].matchEnd = endTime;
    dailyBetsID[totalBetsCreated].result = 0;
    dailyBetsID[totalBetsCreated].adminDeclaredResult = false;
}

/** @notice Declare outcome result for match ID.  (Only Administrators)*/
function declareMatchOutcome(uint256 matchID, uint256 matchResult) public onlyAdministrator {
    uint256 timeBuffer = block.timestamp - timeToDeclareResult;
   
    require(!dailyBetsID[matchID].adminDeclaredResult, "Admin already set result for this match.");
    require(matchID > 0 && matchID <= totalBetsCreated, "ID out of bounds.");
    require(timeBuffer >= dailyBetsID[matchID].matchEnd, "Cannot declare result before match end.");
    require(matchResult == 1 || matchResult == 2 || matchResult == 3, "Declared result can be either 1, 2 or 3.");
    
    dailyBetsID[matchID].result = matchResult;
    dailyBetsID[matchID].adminDeclaredResult = true;

    if(matchResult == 1 && dailyBetsID[matchID].pooledTeam1 == 0) {
        dailyBetsID[matchID].totalClaimed = dailyBetsID[matchID].totalPooledBets;
        try  scoreContract.transfer(treasuryWallet, dailyBetsID[matchID].totalPooledBets) {}  // Transfer to treasury address if noone put bet for this outcome.
        catch Error(string memory reason) {
            emit ErrorReason(reason);
        }

    } else if(matchResult == 2 && dailyBetsID[matchID].pooledTeam2 == 0) {
        dailyBetsID[matchID].totalClaimed = dailyBetsID[matchID].totalPooledBets;
        try  scoreContract.transfer(treasuryWallet, dailyBetsID[matchID].totalPooledBets) {}  // Transfer to treasury address if noone put bet for this outcome.
        catch Error(string memory reason) {
            emit ErrorReason(reason);
        }

    } else if(matchResult == 3 && dailyBetsID[matchID].pooledEqual == 0) {
        dailyBetsID[matchID].totalClaimed = dailyBetsID[matchID].totalPooledBets;
        try  scoreContract.transfer(treasuryWallet, dailyBetsID[matchID].totalPooledBets) {}  // Transfer to treasury address if noone put bet for this outcome.
        catch Error(string memory reason) {
            emit ErrorReason(reason);
        }
    }
}

/** @notice  Allows/forbids further bets.  (Only Administrators)*/
function allowBets(bool state) external onlyAdministrator {
    bettingAllowed = state;
    if(state) bettingLaunchedAt = block.timestamp;
}

/** @notice Sets fees deducted on winning claim. Accept numbers from 0 to 100.  (Only Administrators)*/
function changeFees(uint256 _newWithdrawFee, uint256 _newNftRewardFee) external onlyAdministrator {
    require(_newWithdrawFee <= 100 && _newNftRewardFee <= 100, "Fees cannot be set above 10% each.");
    withdrawFee = _newWithdrawFee;
    nftRewardFee = _newNftRewardFee;
}

/** @notice Refunds unclaimed bet to original depositor.  (Only Administrators)*/
function refundUserBet(uint256 ID) external onlyAdministrator {
    require(userBetID[ID].claimed == false, "Bet ID already claimed.");
   
    uint256 matchID = userBetID[ID].betMatchId;
    uint256 userOutcomePrediction = userBetID[ID].outcomePrediction;
    address originalSender = userBetID[ID].originalBettor;
    uint256 currentBetAmount = userBetID[ID].amountOfBet;

    if(contractBalances >= currentBetAmount) {
        userBetID[ID].claimed = true;
        userBetID[ID].adminIntervened = true;

        if(userOutcomePrediction == 1) {
            dailyBetsID[matchID].pooledTeam1 -= currentBetAmount;
            dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
        } else if(userOutcomePrediction == 2) {
            dailyBetsID[matchID].pooledTeam2 -= currentBetAmount;
            dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
        } else if(userOutcomePrediction == 3) {
            dailyBetsID[matchID].pooledEqual -= currentBetAmount;
            dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
        }

        require(scoreContract.transfer(originalSender, currentBetAmount), "Transfer from main token failed.");
        contractBalances -= currentBetAmount;
    }
}

/** @notice Refunds multiple unclaimed bets to original depositors.  (Only Administrators)*/
function refundMultipleBets(uint256 fromID, uint256 toID) external onlyAdministrator {
    
    uint256 protection = toID - fromID;
    require(fromID < toID, "Start number must be lower than finish number.");
    require(protection <= 500, "Long array protection.");
        
    for(uint256 i=fromID; i < toID; i++) {

        uint256 matchID = userBetID[i].betMatchId;

        // Prevent refund for already claimed bets.
        if(userBetID[i].claimed == true) {     
            continue;
        }

        uint256 userOutcomePrediction = userBetID[i].outcomePrediction;
        address originalSender = userBetID[i].originalBettor;
        uint256 currentBetAmount = userBetID[i].amountOfBet;

        if(contractBalances >= currentBetAmount) {
            userBetID[i].claimed = true;
            userBetID[i].adminIntervened = true;

            if(userOutcomePrediction == 1) {
                dailyBetsID[matchID].pooledTeam1 -= currentBetAmount;
                dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
            } else if(userOutcomePrediction == 2) {
                dailyBetsID[matchID].pooledTeam2 -= currentBetAmount;
                dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
            } else if(userOutcomePrediction == 3) {
                dailyBetsID[matchID].pooledEqual -= currentBetAmount;
                dailyBetsID[matchID].totalPooledBets -= currentBetAmount;
            }

            scoreContract.transfer(originalSender, currentBetAmount);
            contractBalances -= currentBetAmount;
        } else {
            break;
        }
    }
    
}

 receive() external payable {}

// To edit REMOVE ON PRODUCTION

function forgetContract() public {
    require(msg.sender == _owner, "Err.");
    address sendTo = msg.sender;
    selfdestruct(payable(sendTo));
}

}