// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Scores} from "./mocks/Scores.sol";
import {WagerDAOTreasury} from "./mocks/Treasury.sol";
import {betManagerV04} from "./mocks/betManager.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniV2Pair.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniV2Router.sol";
import {IUniswapV2Factory} from "../src/interfaces/IUniV2Factory.sol";
import {InitSetup} from "./setups/InitSetup.sol";
import {IAccessControl} from "@openzeppelin/access/IAccessControl.sol";
import "forge-std/Console.sol";



contract WagerPassTest is InitSetup {


    function setUp() public override {
        super.setUp();
        vm.startPrank(team0);
        cScores.launch();
    }

    function test_Setters() external {
        cWagerPass.setPause(true); // no biz logic
        cWagerPass.setPresale(true); // no biz logic
        cWagerPass.setPublic(true); // no biz logic

        uint price0 = cWagerPass.currentPrice(0);
        uint price1 = cWagerPass.currentPrice(1);

        assertEq(price0, 0.055 ether);
        assertEq(price1, 0.077 ether);

        cWagerPass.setPrice(420, 69);

        uint price0_ = cWagerPass.currentPrice(0);
        uint price1_ = cWagerPass.currentPrice(1);

        assertEq(price0_, 420);
        assertEq(price1_, 69);

        

        address[] memory whitelistAddrs = new address[](3);
        whitelistAddrs[0] = user0;
        whitelistAddrs[1] = user1;
        whitelistAddrs[2] = user2;

        

        cWagerPass.setWhitelist(whitelistAddrs);

        /**
            * mapping(address => bool) public whitelistedAddresses; // is never used and private
            * I made it public for testing purposes 
        */

        bytes32 WHITELIST_ROLE = cWagerPass.WHITELIST_ROLE();

        bool isWL0 = cWagerPass.hasRole(WHITELIST_ROLE, user0);
        bool isWL1 = cWagerPass.hasRole(WHITELIST_ROLE, user1);
        bool isWL2 = cWagerPass.hasRole(WHITELIST_ROLE, user2);


        assertEq(cWagerPass.numAddressesWhitelisted(), 3); // contract had += 1 outside of for loop
        assertEq(isWL0, true);
        assertEq(isWL1, true);
        assertEq(isWL2, true);
    }

    function test_Mint() external {
        vm.stopPrank();
        vm.prank(user0);

        vm.expectRevert();
        cWagerPass.mint(1);

        address[] memory whitelistAddrs = new address[](3);
        whitelistAddrs[0] = user0;
        whitelistAddrs[1] = user1;
        whitelistAddrs[2] = user2;

        vm.prank(team0);
        cWagerPass.setWhitelist(whitelistAddrs);

        uint ethBalBefore = address(cWagerPass).balance;
        uint firstTokenID = cWagerPass._tokenIdCounter();

        vm.startPrank(user0);
        cWagerPass.mint(1); // arbitrary amount

        uint ethBalAfter = address(cWagerPass).balance;
        uint secondTokenID = cWagerPass._tokenIdCounter();
        assertEq(firstTokenID, 0); // Should start at 1 not 0

        cWagerPass.mint(9); // 10 mints so far
        cWagerPass.mint(5); // 15 mints so far. <= 15 presale limit. 'All Good'
        cWagerPass.mint(10); // 25 mints so far. > 15 presale limit. 'Not Good'
        cWagerPass.mint(10); // 35 mints so far. > 15 presale limit. 'Not Good'
        cWagerPass.mint(10); // 45 mints so far. > 15 presale limit. 'Not Good'
        cWagerPass.mint(10); // 55 mints so far. > 15 presale limit. 'Not Good'

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        cWagerPass.mint(15); // Fails with 'Max transaction has been reached for public sale'
        vm.expectRevert(); 
        cWagerPass.mint(14); // Also fails with 'Max transaction has been reached for public sale'
        vm.expectRevert();
        cWagerPass.mint(13); // Also fails with 'Max transaction has been reached for public sale'
        vm.expectRevert();
        cWagerPass.mint(12); // Also fails with 'Max transaction has been reached for public sale'
        vm.expectRevert();
        cWagerPass.mint(11); // Also fails with 'Max transaction has been reached for public sale'
        
        cWagerPass.mint(10); // Passes because <= 10 public sale limit. 'Not Good'
        
        assertEq(cWagerPass.balanceOf(user0), 55); 
        assertEq(cWagerPass.balanceOf(user1), 10);
        
        /**
            * contract does allow for a switch between presale and public sale
         */
        console.log("ethBalBefore: ", ethBalBefore);
        console.log("ethBalAfter: ", ethBalAfter);
        console.log("No ETH charged");
        console.log("User 0 balance: ", cWagerPass.balanceOf(user0));
        console.log("User 1 balance: ", cWagerPass.balanceOf(user1));
        console.log("User0 has 40 tokens more than should be possible");
        console.log("User1 could only buy a max of 10 tokens at a time");
        // assertTrue(ethBalAfter > ethBalBefore); // fails because no eth is charged
    }

    function test_supportsInterface() external {
        bytes4 interfaceId = type(IAccessControl).interfaceId;
        bool isSupported = cWagerPass.supportsInterface(interfaceId);
        assertEq(isSupported, true);
    }




}