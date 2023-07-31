// SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test} from "forge-std/Test.sol";
// import {Scores} from "./mocks/Scores.sol";
// import {ERC20Mock} from "./mocks/ERC20Mock.sol";
// import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
// import {IWETH} from "../src/interfaces/IWETH.sol";
// import {IUniswapV2Pair} from "../src/interfaces/IUniV2Pair.sol";
// import {IUniswapV2Router02} from "../src/interfaces/IUniV2Router.sol";
// import {IUniswapV2Factory} from "../src/interfaces/IUniV2Factory.sol";
// import "forge-std/Console.sol";

// contract ScoresTest is Test {
//     Scores public cScores;

//     address payable public  User1 = payable(address(0x1));
//     address public User2 = address(0x2);

//     address payable public Team1 = payable(address(0x3));
//     address public Team2 = address(0x4);

//     IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
//     IUniswapV2Factory public uniswapV2Factory;
//     IUniswapV2Pair  public uniV2Pair;

//     IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
//     IWETH public WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
//     uint liquidityy;
//     function setUp() public {
//         vm.deal(Team1, 1000 ether);
//         vm.startPrank(Team1);
//         cScores = new Scores();
//         uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
//         uniV2Pair = IUniswapV2Pair(uniswapV2Factory.getPair(address(cScores), address(WETH)));

//         cScores.approve(address(uniswapV2Router), type(uint).max);
//         cScores.approve(address(uniV2Pair), type(uint).max);

//         (uint amountA, uint amountB, uint liq) = uniswapV2Router
//         .addLiquidityETH{value:50 ether}(
//             address(cScores),
//             300_000_000 * 10**9,
//             0,
//             0,
//             Team1,
//             block.timestamp + 100
//             );

//             liquidityy = liq;
//     }

//     function test_DeploymentState() external {
//         assertTrue(address(cScores) != address(0));
//         assertEq(cScores.name(), "Scores");
//         assertEq(cScores.symbol(), "SCORE");
//         assertEq(cScores.totalSupply(), 1_000_000_000 * 10**9);
//         assertEq(cScores.treasuryWallet(), address(0));
//         assertEq(cScores.taxForLiquidity(), 47);
//         assertEq(cScores.taxForTreasury(), 47);
//         assertEq(cScores.maxTxAmount(), 10000001 * 10**9);
//         assertEq(cScores.maxWalletAmount(), 10000001 * 10**9);
//         assertEq(cScores.numTokensSellToAddToLiquidity(), 200000 * 10**9);
//         assertEq(cScores.numTokensSellToAddToETH(), 100000 * 10**9);
//         assertTrue(cScores._isExcludedFromFee(address(uniswapV2Router)));
//         assertTrue(cScores._isExcludedFromFee(Team1));

//         console.log(cScores.totalSupply());
//     }

//     function test_UpdatePair() external {
//         address pair = cScores.uniswapV2Pair();

//         cScores.updatePair(Team2);

//         assertTrue(address(cScores.uniswapV2Pair()) != pair);
//     }

//     function test_ExcludeFromFees() external {
//         assertTrue(cScores._isExcludedFromFee(address(uniswapV2Router)));
//         bool state = cScores._isExcludedFromFee(Team2);

//         cScores.excludeFromFee(Team2, true);

//         assertTrue(cScores._isExcludedFromFee(Team2));
//         bool newState = cScores._isExcludedFromFee(Team2);

//         assertTrue(state != newState);
//     }

//     function test_ChangeTreasury() external {
//         assertEq(cScores.treasuryWallet(), address(0));

//         cScores.changeTreasuryWallet(Team2);
        
//         assertEq(cScores.treasuryWallet(), Team2);
//     }

//     function test_ChangeTax() external {
//         assertEq(cScores.taxForLiquidity(), 47);
//         assertEq(cScores.taxForTreasury(), 47);
        
//         cScores.changeTaxForLiquidityAndTreasury(5, 5);

//         assertEq(cScores.taxForLiquidity(), 5);
//         assertEq(cScores.taxForTreasury(), 5);
//     }

//     function test_ChangeMaxTx() external {
//         assertEq(cScores.maxTxAmount(), 10000001 * 10**9);

//         cScores.changeMaxTxAmount(1000000 * 10**9);
        
//         assertEq(cScores.maxTxAmount(), 1000000 * 10**9);
//     }

//     function test_ChangeMaxWallet() external {
//         assertEq(cScores.maxWalletAmount(), 10000001 * 10**9);

//         cScores.changeMaxWalletAmount(1000000 * 10**9);
        
//         assertEq(cScores.maxWalletAmount(), 1000000 * 10**9);
//     }

//     function test_SimpleTransfer() external {
//         cScores.transfer(Team2, 100);
//         assertEq(cScores.balanceOf(Team2), 100);
//     }

//     function test_SimpleTransferFrom() external {
//         cScores.approve(address(this), 1000);
//         vm.stopPrank();
//         cScores.transferFrom(Team1, Team2, 10);
//         assertEq(cScores.balanceOf(Team2), 10);
//     }

//     function test_SimpleTransferARGS() external {
//         vm.expectRevert();
//         cScores.transfer(Team2, 0);

//         vm.expectRevert();
//         cScores.transfer(address(0), 10000 ether);

//         vm.expectRevert();
//         cScores.transferFrom(address(0), Team2, 0);
//     }

//     function test_BuyFromUniMaxTax() external {
//         vm.stopPrank();
//         vm.deal(User2, 100 ether);
//         vm.startPrank(User2);

//         WETH.deposit{value: 50 ether}();
//         assertEq(WETH.balanceOf(User2), 50 ether);

//         WETH.approve(address(uniswapV2Router), 100 ether);

//         address[] memory path = new address[](2);
//         path[0] = address(WETH);
//         path[1] = address(cScores);

//         uint[] memory amountsOut = uniswapV2Router.getAmountsOut(1 ether, path);
//         uint[] memory amounts = uniswapV2Router.swapTokensForExactTokens(
//             amountsOut[1],
//             amountsOut[0],
//             path,
//             User2,
//             block.timestamp + 360
//         );

//         assertEq(WETH.balanceOf(User2), 49000000000000000145);

//         uint tShare = ((amountsOut[1] * 47) / 100);
//         uint lShare = ((amountsOut[1] * 47) / 100);
//         uint accAmnt = amountsOut[1] - (tShare + lShare);
//         assertEq(cScores.balanceOf(User2), accAmnt);

//         console.log("ETH user spent: ", 1 ether);
//         console.log(accAmnt / 10**9, "Scores for User");
//     }

//     function test_BuyFromUniMinTax() external {
//         cScores.postLaunch();

//         vm.stopPrank();
//         vm.deal(User2, 100 ether);
//         vm.startPrank(User2);

//         WETH.deposit{value: 50 ether}();
//         assertEq(WETH.balanceOf(User2), 50 ether);

//         WETH.approve(address(uniswapV2Router), 100 ether);

//         address[] memory path = new address[](2);
//         path[0] = address(WETH);
//         path[1] = address(cScores);

//         uint[] memory amountsOut = uniswapV2Router.getAmountsOut(1 ether, path);
//         uint[] memory amounts = uniswapV2Router.swapTokensForExactTokens(
//             amountsOut[1],
//             amountsOut[0],
//             path,
//             User2,
//             block.timestamp + 360
//         );

//         console.log("ETH user spent: ", 1 ether);
//         console.log(amountsOut[1] / 10**9, "Scores for User");

//         uint tShare = ((amountsOut[1] * 1) / 100);
//         uint lShare = ((amountsOut[1] * 2) / 100);
//         uint accAmnt = amountsOut[1] - (tShare + lShare);
//         assertEq(cScores.balanceOf(User2), accAmnt);

//     }

//     //// Reverts \\\\\

//     function testRevert_ChangeTax() external {
//         vm.expectRevert();
//         cScores.changeTaxForLiquidityAndTreasury(55, 55);
//     }

//     function testRevert_UpdatePair() external {
//         vm.expectRevert();
//         cScores.updatePair(address(0));
//     }

//     function testRevert_ExcludeFromFees() external {
//         vm.stopPrank();
//         vm.startPrank(User1);
//         vm.expectRevert();
//         cScores.excludeFromFee(address(0), true);
//     }

//     function testRevert_ChangeTreasuryUNAUTHED() external {
//         vm.stopPrank();
//         vm.startPrank(User2);
//         vm.expectRevert();
//         cScores.changeTreasuryWallet(User2);
//     }

//     function testRevert_ChangeTreasuryARGS() external {
//         vm.expectRevert();
//         cScores.changeTreasuryWallet(address(0));
//     }

//     function testRevert_ChangeTaxUNAUTHED() external {
//         vm.stopPrank();
//         vm.startPrank(User2);
//         vm.expectRevert();
//         cScores.changeTaxForLiquidityAndTreasury(2, 1);
//     }

//     function testRevert_ChangeTaxARGS() external {
//         vm.expectRevert();
//         cScores.changeTaxForLiquidityAndTreasury(22, 22);
//     }

//     function testRevert_ChangeSwapUNAUTHED() external {
//         vm.stopPrank();
//         vm.startPrank(User2);
//         vm.expectRevert();
//         cScores.changeSwapThresholds(2 * 1*9, 33 * 10**9);
//     }

//     function testRevert_ChangeSwapARGS() external {
//         vm.expectRevert();
//         cScores.changeSwapThresholds(0 * 10**9, 33 * 10**9);
//     }

//     function testRevert_ChangeMaxTxUNAUTHED() external {
//         vm.stopPrank();
//         vm.startPrank(User2);
//         vm.expectRevert();
//         cScores.changeMaxTxAmount(10 * 10**9);
//     }

//     function testRevert_ChangeMaxTxARGS() external {
//         vm.expectRevert();
//         cScores.changeMaxTxAmount(0);
//     }

//     function testRevert_MaxWalletUNAUTHED() external {
//         vm.stopPrank();
//         vm.startPrank(User2);
//         vm.expectRevert();
//         cScores.changeMaxWalletAmount(10 * 10**9);
//     }

//     function testRevert_MaxWalletARGS() external {
//         vm.expectRevert();
//         cScores.changeMaxWalletAmount(0);
//     }

//     //// Failing Tests \\\\\
    
//     function test_Decimals() external {
//         uint ERC20Decmials = cScores.decimals();
//         uint SCOREDecimals = cScores._decimals();

//         assertEq(ERC20Decmials, SCOREDecimals);

//         /* @audit - Inaccurate accounting and handling of tokens by
//          * external parties as they'll call decimals() returning 18
//          * while contract uses 9 internally.
//         */
//     }

//     function test_ChangeSwapThreshold() external {
//         assertEq(cScores.numTokensSellToAddToLiquidity(), 200000 * 10**9);
//         assertEq(cScores.numTokensSellToAddToETH(), 100000 * 10**9);

//         cScores.changeSwapThresholds(1, 1);
//         vm.warp(1);
//         vm.roll(1);

//         assertEq(cScores.numTokensSellToAddToLiquidity(), 1 * 10**9);
//         assertEq(cScores.numTokensSellToAddToETH(), 1 * 10**9);
//     }

// }
