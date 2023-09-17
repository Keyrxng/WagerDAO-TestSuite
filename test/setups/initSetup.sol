import {Test} from "forge-std/Test.sol";
import {mockScores} from "../mocks/Scores.sol";
import {mockWagerDAOTreasury} from "../mocks/Treasury.sol";
import {mockBetManager_V01} from "../mocks/betManager.sol";
import {mockWager_DAO_NFT} from "../mocks/WagerPass.sol";
import {mockWagerDAO} from "../mocks/WagerDAO.sol";
import {mockERC20Mock} from "../mocks/ERC20Mock.sol";
import {IWETH} from "../../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../../src/interfaces/IUniV2Factory.sol";
import {mockNFTBetFeesDistributor} from "../mocks/FeeDistributor.sol";
import "forge-std/Console.sol";

contract InitSetup is Test {
    mockScores internal cScores;
    mockWagerDAOTreasury internal cTreasury;
    mockBetManager_V01 internal cBetManager;
    mockWager_DAO_NFT internal cWagerPass;
    mockNFTBetFeesDistributor internal cFeeDistro;


    IUniswapV2Router02 internal constant uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //bsc testnet
    IUniswapV2Factory internal uniswapV2Factory;
    IUniswapV2Pair  internal uniV2Pair;

    IWETH internal WETH;
    
    uint internal liquidityy;
    uint internal token0Liq;
    uint internal token1Liq;

    address internal team0 = makeAddr("team0");
    address internal team1 = makeAddr("team1");
    address internal team2 = makeAddr("team2");

    address internal user0 = makeAddr("user0");
    address internal user1 = makeAddr("user1");
    address internal user2 = makeAddr("user2");

    function setUp() virtual public {
        vm.deal(team0, 150 ether);
        vm.startPrank(team0);

        cScores = new mockScores(); //new deployment flow
        cWagerPass = new mockWager_DAO_NFT(); //new deployment flow

        cTreasury = new mockWagerDAOTreasury(address(cScores), address(cWagerPass));

        cFeeDistro = new mockNFTBetFeesDistributor(address(cScores), address(cWagerPass)); //new deployment flow
        
        cBetManager = new mockBetManager_V01(address(cScores), address(cFeeDistro)); 
        
        cScores.setTreasury(address(cTreasury)); // required becaused of constructor errors of original design
        cWagerPass.setTreasury(address(cTreasury)); // required becaused of constructor errors of original design
        cFeeDistro.setBetManager(address(cBetManager)); // required becaused of constructor errors of original design
        
        WETH = IWETH(uniswapV2Router.WETH());
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniV2Pair = IUniswapV2Pair(cScores.uniswapV2Pair());
        
        if (uniV2Pair == IUniswapV2Pair(address(0))) {
            uniV2Pair = IUniswapV2Pair(uniswapV2Factory.createPair(address(cScores), address(WETH)));
        }

        cScores.approve(address(uniswapV2Router), type(uint).max);
        cScores.approve(address(uniV2Pair), type(uint).max);

        WETH.deposit{value: 50 ether}();
        
        WETH.approve(address(uniswapV2Router), type(uint).max);
        WETH.approve(address(uniV2Pair), type(uint).max);

        (uint amountA, uint amountB, uint liq) = uniswapV2Router
        .addLiquidityETH{value:50 ether}(
            address(cScores),
            300_000_000 * 10**9,
            0,
            0,
            team0,
            block.timestamp + 100
            );

            liquidityy = liq;
            token0Liq = amountA;
            token1Liq = amountB;
        vm.stopPrank();
    }

    function test_InitSetup() external {
        assertTrue(address(cScores) != address(0));
        assertTrue(address(cTreasury) != address(0));
        assertTrue(address(cBetManager) != address(0));
        assertTrue(address(cWagerPass) != address(0));
        assertTrue(address(cFeeDistro) != address(0));
        assertTrue(address(WETH) != address(0));
        assertTrue(address(uniswapV2Router) != address(0));
        assertTrue(address(uniswapV2Factory) != address(0));
        assertTrue(address(uniV2Pair) != address(0));
        assertTrue(liquidityy > 0);
        assertTrue(token0Liq > 0);
        assertTrue(token1Liq > 0);
    }
}