// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {Scores} from "../src/Scores.sol";
import {Wager_DAO_NFT} from "../src/WagerPass.sol";
import {WagerDAOTreasury} from "../src/Treasury.sol";
import {betManager_V01} from "../src/betManager.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../src/interfaces/IUniV2Factory.sol";
import {NFTBetFeesDistributor} from "../src/FeeDistributor.sol";

/* 
```
forge script deploy --rpc-url https://rpc-mumbai.maticvigil.com --private-key 00000 -vvv --broadcast --ffi
```
**/

contract deploy is Script {
    Scores public cScores;
    Wager_DAO_NFT public cWagerPass;
    WagerDAOTreasury public cTreasury;
    betManager_V01 public cBetManager;
    NFTBetFeesDistributor public cFeeDistro;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Pair public uniV2Pair;
    IWETH public WETH = IWETH(0x5B67676a984807a212b1c59eBFc9B3568a474F0a);
    
    uint256 public liquidityy;
    uint256 public token0Liq;
    uint256 public token1Liq;

    function run() public {
        vm.startBroadcast();
        cScores = new Scores(); 
        cWagerPass = new Wager_DAO_NFT(); 

        cTreasury = new WagerDAOTreasury(address(cScores), address(cWagerPass));

        cFeeDistro = new NFTBetFeesDistributor(address(cScores), address(cWagerPass)); 
        
        cBetManager = new betManager_V01(address(cScores), address(cFeeDistro)); 
        
        cScores.setTreasury(address(cTreasury)); 
        cWagerPass.setTreasury(address(cTreasury)); 
        cFeeDistro.setBetManager(address(cBetManager)); 
        
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniV2Pair = IUniswapV2Pair(cScores.uniswapV2Pair());
        
        if (uniV2Pair == IUniswapV2Pair(address(0))) {
            uniV2Pair = IUniswapV2Pair(uniswapV2Factory.createPair(address(cScores), address(WETH)));
        }

        cScores.approve(address(uniswapV2Router), type(uint).max);
        cScores.approve(address(uniV2Pair), type(uint).max);

        WETH.deposit{value: 0.5 ether}();
        
        WETH.approve(address(uniswapV2Router), type(uint).max);
        WETH.approve(address(uniV2Pair), type(uint).max);

        (uint amountA, uint amountB, uint liq) = uniswapV2Router
        .addLiquidityETH{value:0.5 ether}(
            address(cScores),
            500_000_000 * 1e9,
            0,
            0,
            tx.origin,
            block.timestamp + 100
            );

            liquidityy = liq;
            token0Liq = amountA;
            token1Liq = amountB;

            vm.stopBroadcast();
            assert(intergrationTest() == true);
    }

    function intergrationTest() internal view returns(bool) {
        require(address(cScores) != address(0), "cScores not deployed");
        require(address(cWagerPass) != address(0), "cWagerPass not deployed");
        require(address(cTreasury) != address(0), "cTreasury not deployed");
        require(address(cBetManager) != address(0), "cBetManager not deployed");
        require(address(cFeeDistro) != address(0), "cFeeDistro not deployed");
        require(address(uniswapV2Router) != address(0), "uniswapV2Router not deployed");
        require(address(uniswapV2Factory) != address(0), "uniswapV2Factory not deployed");
        require(address(uniV2Pair) != address(0), "uniV2Pair not deployed");
        require(address(WETH) != address(0), "WETH not deployed");
        return true;
    }
}