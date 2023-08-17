import {Test} from "forge-std/Test.sol";
import {Scores} from "../mocks/Scores.sol";
import {WagerDAOTreasury} from "../mocks/Treasury.sol";
import {betManager_V01} from "../mocks/betManager.sol";
import {Wager_DAO_NFT} from "../mocks/WagerPass.sol";
import {WagerDAO} from "../mocks/WagerDAO.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {IWETH} from "../../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../../src/interfaces/IUniV2Factory.sol";
import {NFTBetFeesDistributor} from "../mocks/FeeDistributor.sol";
import "forge-std/Console.sol";

contract InitSetup is Test {
    Scores internal cScores;
    WagerDAOTreasury internal cTreasury;
    betManager_V01 internal cBetManager;
    Wager_DAO_NFT internal cWagerPass;
    NFTBetFeesDistributor internal cFeeDistro;
    ERC20Mock internal cERC20Mock;


    IUniswapV2Router02 internal constant uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //bsc testnet
    IUniswapV2Factory internal uniswapV2Factory;
    IUniswapV2Pair  internal uniV2Pair;
    IUniswapV2Pair  internal uniV2PairBUSD;

    IWETH internal BUSD;
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

        cScores = new Scores(); //new deployment flow
        cWagerPass = new Wager_DAO_NFT(); //new deployment flow

        cTreasury = new WagerDAOTreasury(address(cScores), address(cWagerPass));

        cFeeDistro = new NFTBetFeesDistributor(address(cScores), address(cWagerPass)); //new deployment flow
        
        cBetManager = new betManager_V01(address(cScores), address(cFeeDistro)); 
        
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
}