// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.7;

// import "@openzeppelin/token/ERC20/ERC20.sol";
// import "@openzeppelin/access/Ownable.sol";
// import "@uniswapV2Core/UniswapV2Factory.sol";


// contract Scores is ERC20, Ownable {

//     string private _name = "Scores";
//     string private _symbol = "SCORE";
//     uint8 private _decimals = 9;
//     uint256 private _supply = 1000000000;
//     // Anti-Bot / Will be lowered after launch
//     uint256 public taxForLiquidity = 47;
//     // Anti-Bot / Will be lowered after launch
//     uint256 public taxForTreasury = 47; 
//     uint256 public maxTxAmount = 10000001 * 10**_decimals;
//     uint256 public maxWalletAmount = 10000001 * 10**_decimals;
//     address public treasuryWallet = "";
//     address public DEAD = 0x000000000000000000000000000000000000dEaD;
//     uint256 public _treasuryReserves = 0;
//     mapping(address => bool) public _isExcludedFromFee;
//     uint256 public numTokensSellToAddToLiquidity = 200000 * 10**_decimals;
//     uint256 public numTokensSellToAddToETH = 100000 * 10**_decimals;

//     function postLaunch() external onlyOwner {
//         taxForLiquidity = 1;
//         taxForTreasury = 2;
//         maxTxAmount = 10000001 * 10**_decimals;
//         maxWalletAmount = 10000001 * 10**_decimals;
//     }

//     IUniswapV2Router02 public immutable uniswapV2Router;
//     address public uniswapV2Pair;
    
//     bool inSwapAndLiquify;

//     event SwapAndLiquify(
//         uint256 tokensSwapped,
//         uint256 ethReceived,
//         uint256 tokensIntoLiqudity
//     );

//     modifier lockTheSwap() {
//         inSwapAndLiquify = true;
//         _;
//         inSwapAndLiquify = false;
//     }

//     /**
//      * @dev Sets the values for {name} and {symbol}.
//      *
//      * The default value of {decimals} is 18. To select a different value for
//      * {decimals} you should overload it.
//      *
//      * All two of these values are immutable: they can only be set once during
//      * construction.
//      */
//     constructor() ERC20(_name, _symbol) {
//         _mint(msg.sender, (_supply * 10**_decimals));

//         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //eth mainnet
//         uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

//         uniswapV2Router = _uniswapV2Router;

//         _isExcludedFromFee[address(uniswapV2Router)] = true;
//         _isExcludedFromFee[msg.sender] = true;
//         _isExcludedFromFee[treasuryWallet] = true;
//     }

//     function updatePair(address _pair) external onlyOwner {
//         require(_pair != DEAD, "LP Pair cannot be the Dead wallet, or 0!");
//         require(_pair != address(0), "LP Pair cannot be the Dead wallet, or 0!");
//         uniswapV2Pair = _pair;
//         emit PairUpdated(_pair);
//     }

//     /**
//      * @dev Moves `amount` of tokens from `from` to `to`.
//      *
//      * This internal function is equivalent to {transfer}, and can be used to
//      * e.g. implement automatic token fees, slashing mechanisms, etc.
//      *
//      * Emits a {Transfer} event.
//      *
//      * Requirements:
//      *
//      *
//      * - `from` cannot be the zero address.
//      * - `to` cannot be the zero address.
//      * - `from` must have a balance of at least `amount`.
//      */
//     function _transfer(address from, address to, uint256 amount) internal override {
//         require(from != address(0), "ERC20: transfer from the zero address");
//         require(to != address(0), "ERC20: transfer to the zero address");
//         require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");

//         if ((from == uniswapV2Pair || to == uniswapV2Pair) && !inSwapAndLiquify) {
//             if (from != uniswapV2Pair) {
//                 uint256 contractLiquidityBalance = balanceOf(address(this)) - _treasuryReserves;
//                 if (contractLiquidityBalance >= numTokensSellToAddToLiquidity) {
//                     _swapAndLiquify(numTokensSellToAddToLiquidity);
//                 }
//                 if ((_treasuryReserves) >= numTokensSellToAddToETH) {
//                     _swapTokensForEth(numTokensSellToAddToETH);
//                     _treasuryReserves -= numTokensSellToAddToETH;
//                     bool sent = payable(treasuryWallet).send(address(this).balance);
//                     require(sent, "Failed to send ETH");
//                 }
//             }

//             uint256 transferAmount;
//             if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
//                 transferAmount = amount;
//             } 
//             else {
//                 require(amount <= maxTxAmount, "ERC20: transfer amount exceeds the max transaction amount");
//                 if(from == uniswapV2Pair){
//                     require((amount + balanceOf(to)) <= maxWalletAmount, "ERC20: balance amount exceeded max wallet amount limit");
//                 }

//                 uint256 treasuryShare = ((amount * taxForTreasury) / 100);
//                 uint256 liquidityShare = ((amount * taxForLiquidity) / 100);
//                 transferAmount = amount - (treasuryShare + liquidityShare);
//                 _treasuryReserves += treasuryShare;

//                 super._transfer(from, address(this), (treasuryShare + liquidityShare));
//             }
//             super._transfer(from, to, transferAmount);
//         } 
//         else {
//             super._transfer(from, to, amount);
//         }
//     }

//     function excludeFromFee(address _address, bool _status) external onlyOwner {
//         _isExcludedFromFee[_address] = _status;
//         emit ExcludedFromFeeUpdated(_address, _status);
//     }
//     //Swap tokens for ETH and add to liquidity
//     function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
//         uint256 half = (contractTokenBalance / 2);
//         uint256 otherHalf = (contractTokenBalance - half);

//         uint256 initialBalance = address(this).balance;

//         _swapTokensForEth(half);

//         uint256 newBalance = (address(this).balance - initialBalance);

//         _addLiquidity(otherHalf, newBalance);

//         emit SwapAndLiquify(half, newBalance, otherHalf);
//     }

//     function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
//         address[] memory path = new address[](2);
//         path[0] = address(this);
//         path[1] = uniswapV2Router.WETH();

//         _approve(address(this), address(uniswapV2Router), tokenAmount);

//         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             tokenAmount,
//             0,
//             path,
//             address(this),
//             block.timestamp
//         );
//     }

//     function _addLiquidity(uint256 tokenAmount, uint256 ethAmount)
//         private
//         lockTheSwap
//     {
//         _approve(address(this), address(uniswapV2Router), tokenAmount);

//         uniswapV2Router.addLiquidityETH{value: ethAmount}(
//             address(this),
//             tokenAmount,
//             0,
//             0,
//             treasuryWallet,
//             block.timestamp
//         );
//     }

//     function changeTreasuryWallet(address newWallet)
//         public
//         onlyOwner
//         returns (bool)
//     {
//         require(newWallet != DEAD, "LP Pair cannot be the Dead wallet, or 0!");
//         require(newWallet != address(0), "LP Pair cannot be the Dead wallet, or 0!");
//         treasuryWallet = newWallet;
//         return true;
//     }

//     function changeTaxForLiquidityAndTreasury(uint256 _taxForLiquidity, uint256 _taxForTreasury)
//         public
//         onlyOwner
//         returns (bool)
//     {
//         require((_taxForLiquidity+_taxForTreasury) <= 10, "ERC20: total tax must not be greater than 10%");
//         taxForLiquidity = _taxForLiquidity;
//         taxForTreasury = _taxForTreasury;

//         return true;
//     }

//     function changeSwapThresholds(uint256 _numTokensSellToAddToLiquidity, uint256 _numTokensSellToAddToETH)
//         public
//         onlyOwner
//         returns (bool)
//     {
//         require(_numTokensSellToAddToLiquidity < _supply / 98, "Cannot liquidate more than 2% of the supply at once!");
//         require(_numTokensSellToAddToETH < _supply / 98, "Cannot liquidate more than 2% of the supply at once!");
//         numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity * 10**_decimals;
//         numTokensSellToAddToETH = _numTokensSellToAddToETH * 10**_decimals;

//         return true;
//     }

//     function changeMaxTxAmount(uint256 _maxTxAmount)
//         public
//         onlyOwner
//         returns (bool)
//     {
//         maxTxAmount = _maxTxAmount;

//         return true;
//     }

//     function changeMaxWalletAmount(uint256 _maxWalletAmount)
//         public
//         onlyOwner
//         returns (bool)
//     {
//         maxWalletAmount = _maxWalletAmount;

//         return true;
//     }

//     receive() external payable {}
// }