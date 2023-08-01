// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/security/Pausable.sol";
import "@openzeppelin/access/AccessControl.sol";
import "@openzeppelin/utils/Counters.sol";
import "@openzeppelin/security/ReentrancyGuard.sol";

contract WagerPass is ERC721, Pausable, AccessControl, ReentrancyGuard {
    using Counters for Counters.Counter;

    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
        
    Counters.Counter private _tokenIdCounter;
    
// Treasury Wallet
    address treasury;
// WagerPass URI
    string public wagerPassURI;
// Presale / Public State
    uint8[2] public state = [0, 1];
// Mint price per release Presale / Public
    uint256[2] public mintPrice = [0.055 ether, 0.077 ether];
// WagerPass Supply per release Presale / Public
    uint256[2] public maxSupply = [2500,2500];
// Max WagerPasses per Transaction per release Presale / Public
    uint32[3] public maxPerTX = [15, 10];
// Max WagerPasses per Address per release Presale / Public
    uint32[3] public maxPerAddress = [15,10];
// Maximum whitelisted Addresses
    uint32 public maxWhitelistedAddresses = 2000;
// Number of addresses Whitelisted
    uint32 public numAddressesWhitelisted;

// Mappings
    mapping(address => bool) private whitelistedAddresses;



    // Treasury wallet set upon deployment, changeable later by admin.
    constructor(string memory _wagerPassURI, address _treasury) ERC721("WagerPass", "WPASS") {

    treasury = (_treasury);    
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(STAFF_ROLE, msg.sender);
        _grantRole(WHITELIST_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        
        wagerPassURI = _wagerPassURI;
    }
    

    
// Staff Functions

    function setPause(bool _pause) public onlyRole(STAFF_ROLE){
    }
    
    function setPresale(bool) public onlyRole(STAFF_ROLE) {
        
    }

    function setPublic(bool) public onlyRole(STAFF_ROLE) {
       
    }

    // Mint
    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
    // Set Price of WagerPasses per release
    function setPrice(uint256 _presalePrice, uint256 _publicPrice) external onlyRole(STAFF_ROLE) {
        mintPrice[0] = _presalePrice;
        mintPrice[1] = _publicPrice;
	}

    // Add to whitelist
    function setWhitelist(address[] memory _whitelistedAddresses) public onlyRole(STAFF_ROLE) {

        require(numAddressesWhitelisted < maxWhitelistedAddresses, "More addresses can't be added during Presale, limit reached");

       for(uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            _grantRole(WHITELIST_ROLE, _whitelistedAddresses[i]);
        }

        numAddressesWhitelisted += 1;
    }
    
    function setTreasuryWallet(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }



    // Mint WagerPass - Presale/Public
 
    function mint(uint256 numOfPasses) public payable nonReentrant {
        
        require(numOfPasses <= maxPerTX[0], "Max transaction has been reached for presales");
        require(numOfPasses <= maxPerTX[1], "Max transaction has been reached for public sale");
        require(hasRole(WHITELIST_ROLE, _msgSender()), "You have not been whitelisted");
        

        for(uint256 i; i < numOfPasses; i++){
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint( _msgSender(), tokenId );
        }
    }
    
        

    // Withdraw Funds To Treasury
    function withdraw() public payable nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 numTokens = _tokenIdCounter.current();
        payable(treasury).transfer(address(this).balance);      
    }

    // View Contracts Current Balance
    function currentFunds() public view returns(uint256) {
        return address(this).balance;
    }
    // View current price of WagerPass
    function currentPrice(uint256 _index) public view returns(uint256) {
        return mintPrice[_index];
    }
    // View total supply of WagerPass 
    function totalSupply() public view returns(uint256) {
        return _tokenIdCounter.current();
    }

// The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}