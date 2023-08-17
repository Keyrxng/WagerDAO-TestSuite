// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { IUniswapV2Router02 } from "../../src/interfaces/IUniV2Router.sol";
import { IUniswapV2Factory } from "../../src/interfaces/IUniV2Factory.sol";

interface ITreasury {
    function distributeFeeTokens(uint256 tokens) external;
}

contract Scores is ERC20, Ownable {

string private _name = "Scores";
string private _symbol = "SCORE";
uint256 private _supply = 1_000_000_000 * 1e9;

// Anti-Bot / Will be lowered after launch
uint256 public buyTaxes = 470;
uint256 public sellTaxes = 470; 
uint256 public divider = 1000;

uint256 public maxTxAmount = 10_000_001 * 1e9;
uint256 public maxWalletAmount = 10_000_001 * 1e9;
address public treasuryAddress;
address public DEAD = 0x000000000000000000000000000000000000dEaD;

mapping(address => bool) public _isExcludedFromFee;
mapping(address => bool) public canTransferBeforeLaunch;

// Auto swap settings
uint256 public swapThrehold = 200_000 * 1e9;
uint256 public treasuryShare = 70;
uint256 public liquidityShare = 30;
bool public autoSwapEnabled = true;
bool public isItLaunched;
IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;

bool inSwapAndLiquify;

event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,  uint256 tokensIntoLiqudity);

modifier lockTheSwap() {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
}

constructor() ERC20(_name, _symbol) {

   address currentRouter;
    
    // Polygon Mumbai testnet
    if(block.chainid == 80001) {
       currentRouter = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    
    // BSC Testnet
    } else if(block.chainid == 97) {
        currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; 

    // Cronos Testnet
    } else if(block.chainid == 338) {
        currentRouter = 0x2fFAa0794bf59cA14F268A7511cB6565D55ed40b;

    // Fantom Testnet
    } else if(block.chainid == 4002) {
        currentRouter = 0x90D4e9eB792602AA7A7506b477B878307C35e24A;

    // Avalanche Testnet
    } else if(block.chainid == 43113) {
        currentRouter = 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901; 

    // Goerli Testnet
    } else if(block.chainid == 5) {
        currentRouter = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    // BSC Mainnet (PCS V2)
    } else if(block.chainid == 56) {
        currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 

    // ETH Mainnet (UNI V2)
    } else if(block.chainid == 1) {
        currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
    }   else if(block.chainid == 31337) {
        currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; 
    }
    
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
    _isExcludedFromFee[address(uniswapV2Router)] = true;
    _isExcludedFromFee[msg.sender] = true;
    _isExcludedFromFee[treasuryAddress] = true;
    canTransferBeforeLaunch[msg.sender] = true;
    
    _mint(msg.sender,  _supply);
    emit Transfer(address(0), msg.sender, _supply);
}

function setTreasury(address tr) external onlyOwner {
    treasuryAddress = tr;
}

function setUniPair(address addr) external onlyOwner {
    uniswapV2Pair = addr;
}

// @notice: is now auth guarded
function burn(uint256 coins) public onlyOwner {
    _burn(msg.sender, coins);
}

// @notice: overrides decimals 18 > 9
function decimals() public view virtual override returns (uint8) {
    return 9;
}

function _transfer(address from, address to, uint256 amount) internal override {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");

    if(!isItLaunched) {
        require(canTransferBeforeLaunch[from] || canTransferBeforeLaunch[to],
        "Not launched yet.");
    }

    if ((from == uniswapV2Pair || to == uniswapV2Pair) && !inSwapAndLiquify) {

        uint256 transferAmount;
        uint256 taxAmount = 0;

        if (to == uniswapV2Pair) {
            uint256 contractBalances = balanceOf(address(this));
            if(autoSwapEnabled && (contractBalances >= swapThrehold)) {
                swapTokensForEthWithShares(swapThrehold);
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            transferAmount = amount;
        } else {
            if(from == uniswapV2Pair) {
                require((amount + balanceOf(to)) <= maxWalletAmount, "ERC20: balance amount exceeded max wallet amount limit");
                require(amount <= maxTxAmount, "ERC20: transfer amount exceeds the max transaction amount");
                taxAmount = amount * buyTaxes / divider;
            } else if (to == uniswapV2Pair) {
                taxAmount = amount * sellTaxes / divider;
            }

            transferAmount = amount - taxAmount;
            super._transfer(from, address(this), taxAmount);
        }

        super._transfer(from, to, transferAmount);

    } else {
        super._transfer(from, to, amount);
    }
}

function swapTokensForEthWithShares(uint256 tokenAmount) private lockTheSwap {

    if(tokenAmount == 0) {
        return;
    }

    uint256 currentContractBalance = balanceOf(address(this));
    if(tokenAmount > currentContractBalance) {
        tokenAmount = currentContractBalance;
    }

    uint256 tokensForLiquidity = tokenAmount * liquidityShare / 100;
    uint256 tokensForTreasury = tokenAmount * treasuryShare / 100;

    if(tokensForTreasury > 0) {
        _burn(address(this), tokensForTreasury);
        _mint(treasuryAddress, tokensForTreasury);

        emit Transfer(address(this), treasuryAddress, tokenAmount);
    }

    if(tokensForLiquidity > 0) {
       swapAndAddLiquidity(tokensForLiquidity);
    }
}

//Swap tokens for ETH and add to liquidity
function swapAndAddLiquidity(uint256 tokenAmount) public {
    uint256 half = tokenAmount / 2;
    uint256 initialBalance = address(this).balance;
    _swapTokensForEth(half); // Swap tokens for ETH increasing the balance
    uint256 newBalance = address(this).balance - initialBalance; // How much ETH did we just swap into?
    _addLiquidity(half, newBalance);
    emit SwapAndLiquify(half, newBalance, half);
}

//Swap tokens for ETH
function _swapTokensForEth(uint256 tokenAmount) public {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
}

function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) public {
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, treasuryAddress, block.timestamp);
}


// Read functions

function currentTaxes() public view returns(uint256 buyTax, uint256 sellTax) {
    return(buyTaxes, sellTaxes);
}

function currentLimits() public view returns(uint256 maxWallet, uint256 maxTx) {
    return(maxWalletAmount, maxTxAmount);
}

function currentTreasury() public view returns(address currentTreasuryAddress) {
    return(treasuryAddress);
}

function currentSwapSettings() public view returns(bool autoSwap, uint256 tresholdForSwap, uint256 shareForTreasury, uint256 shareForLiquidity) {
    return(autoSwapEnabled, swapThrehold, treasuryShare, liquidityShare);
}

function isExcludedFromRestrictions(address who) public view returns (bool feesExcluded, bool canDoPrelaunchTransfer) {
    return(_isExcludedFromFee[who], canTransferBeforeLaunch[who]);
}

// Owner only functions

function preLaunchTransfer(address who, bool status) public onlyOwner {
    canTransferBeforeLaunch[who] = status;
}

function updatePair(address _pair) public onlyOwner {
    require(_pair != DEAD, "LP Pair cannot be the Dead wallet, or 0!");
    require(_pair != address(0), "LP Pair cannot be the Dead wallet, or 0!");
    uniswapV2Pair = _pair;
}

/** @notice Sets initial transaction settings and allow token trading on DEX. */
function launch() external onlyOwner {
    isItLaunched = true;
    buyTaxes = 30;
    sellTaxes = 30;
    maxTxAmount = 10_000_001 * 1e9;
    maxWalletAmount = 10_000_001 * 1e9;
}

/** @notice Withdraw stuck score tokens from the contract. */
function manualSendToTreasury() public onlyOwner {
    uint256 currentBalance = balanceOf(address(this));
    super._transfer(address(this), treasuryAddress, currentBalance);
    try ITreasury(treasuryAddress).distributeFeeTokens(currentBalance) {} catch {}
}

/** @notice Withdraw stuck ETH from the contract. */
function withdrawETH() public onlyOwner {
   (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
   require(success, "ETH Transfer failed.");
}

/** @notice Changes current treasury address with new one. New treasury should be contract address. */
function changeTreasuryAddress(address newAddress) public onlyOwner {
    require(newAddress != DEAD, "LP Pair cannot be the Dead wallet, or 0!");
    require(newAddress != address(0), "LP Pair cannot be the Dead wallet, or 0!");
    require(newAddress.code.length > 0, "Only can set contract as treasury.");
    treasuryAddress = newAddress;
}

/** @notice Changes token buy/sell fees. */
function changeTaxes(uint256 newBuyTax, uint256 newSellTax) public onlyOwner {
    require((newBuyTax + newSellTax) <= 100, "ERC20: total tax must not be greater than 10%");
    buyTaxes = newBuyTax;
    sellTaxes = newSellTax;
}

/** @notice Changes contract's auto swap settings. */
function changeSwapSettings(bool autoSwap, uint256 tokensToSwap, uint256 treasuryPercent, uint256 liquidityPercent) public onlyOwner {
    require((treasuryPercent + liquidityPercent) == 100, "Treasury + liquidy must be equal to 100.");
    require(tokensToSwap >= 1, "Cannot set below 1 token.");
    require(tokensToSwap < (_supply * 1 / 100) / 1e9, "Cannot liquidate more than 1% of the supply at once!");

    autoSwapEnabled = autoSwap;
    swapThrehold = tokensToSwap * 1e9;
    treasuryShare = treasuryPercent;
    liquidityShare = liquidityPercent;
}

/** @notice Excludes address from buy/sell fees. */
function excludeFromFee(address _address, bool _status) public onlyOwner {
    _isExcludedFromFee[_address] = _status;
}

/** @notice Changes current max transaction amount. */
function changeMaxTxAmount(uint256 _maxTxAmount) public onlyOwner {
    require(_maxTxAmount >= _supply / 1000, "Cannot set below 0.1% of total supply.");
    maxTxAmount = _maxTxAmount;
}

/** @notice Changes current max wallet holdings limit. */
function changeMaxWalletAmount(uint256 _maxWalletAmount) public onlyOwner {
    require(_maxWalletAmount >= _supply / 1000, "Cannot set below 0.1% of total supply.");
    maxWalletAmount = _maxWalletAmount;
}

receive() external payable {}

}