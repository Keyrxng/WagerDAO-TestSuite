import {Test} from "forge-std/Test.sol";
import "forge-std/Console.sol";
import {InitSetup} from "./setups/initSetup.sol";

contract WagerPassBasicTest is InitSetup {
    
    function setUp() override public {
        super.setUp();
        // team0 has 50ETH 
        // LP has 300M tokens and 50WETH
        // vm.prank(team0);
        // cScores.transfer(user0, 100 * 1e9);
    }


    function test_cWagerPassState() external {
        assertEq(address(cWagerPass.treasury()), address(cTreasury));
        assertEq(cWagerPass.hasRole(cWagerPass.MINTER_ROLE(), team0), true);
        assertEq(cWagerPass.uri(), "WillAssignLater");
        assertEq(cWagerPass.price(), 0.1 ether);
        assertEq(cWagerPass.totalSupply(), 0);
        assertEq(cWagerPass.name(), "Score NFT");
        assertEq(cWagerPass.symbol(), "SNFT");
    }

    function test_cWagerPass_NoAuth() external {
        vm.startPrank(user0);

        vm.expectRevert();
        cWagerPass.updateUri('lol');

        vm.expectRevert();
        cWagerPass.updateMintPrice(999999999999);

        vm.expectRevert();
        cWagerPass.safeMint{value: 0.001 ether}(user0);
    }

    function test_cWagerPass_WAuth() external {
        vm.deal(team0, 999999999999 ether);
        vm.startPrank(team0);

        cWagerPass.updateUri('lol');
        cWagerPass.updateMintPrice(999999999999);
        assertEq(cWagerPass.price(), 999999999999 * 1e17);
        cWagerPass.safeMint{value: 999999999999 * 1e17}(user0);
        assertEq(cWagerPass.tokenURI(1), 'lol');

        cWagerPass.setTreasury(address(this));
        assertEq(address(cWagerPass.treasury()), address(this));

        assertEq(cWagerPass.supportsInterface(0x01ffc9a7), true);

        vm.stopPrank();
    }

}

contract WagerPassDeepTest is InitSetup {
    function setUp() override public {
        super.setUp();
        vm.startPrank(team0);
        cScores.launch();
        cScores.transfer(user0, 10_000 * 1e9);
        cScores.transfer(user1, 10_000 * 1e9);
        cScores.transfer(address(cTreasury), 1_000_000 * 1e9);

        vm.deal(address(cTreasury), 5 ether);
        vm.deal(user0, 2 ether);
        vm.deal(user1, 2 ether);
        vm.deal(team1, 2 ether);

        vm.stopPrank();
    }

    /**
    function setTreasury(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    error TransferFailed(string reason);

    function safeMint(address to) public payable returns (uint256) {
        require(msg.value >= price,"Invalid price");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        (bool success, ) = treasury.call{value: msg.value}("");

        if(!success) {
            revert TransferFailed(" Try again in a few minutes, ETH failed to transfer.");
        }

        return tokenId;
    }

    function updateUri(string memory _uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uri = _uri;
    }

    function updateMintPrice(uint256 newPrice) public onlyRole(DEFAULT_ADMIN_ROLE) {
        price = newPrice * 1e17;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
     */

    function test_cWagerPass_MultiMint() external {
        vm.startPrank(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        cWagerPass.safeMint{value: 0.1 ether}(user0);
        vm.stopPrank();

        assertEq(cWagerPass.balanceOf(user0), 9);
        assertEq(cWagerPass.totalSupply(), 9);

        for(uint x = 0; x < 9; x++) {
            assertEq(cWagerPass.tokenOfOwnerByIndex(user0, x), x + 1);
        }
    }

}