// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721URIStorage } from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import { AccessControl } from "@openzeppelin/access/AccessControl.sol";
import { Counters } from "@openzeppelin/utils/Counters.sol";
import "./interfaces/ITreasury.sol";

contract Wager_DAO_NFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControl
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    address public treasury;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public uri = "WillAssignLater";
    uint256 public price = 0.1 ether;
    
    error TransferFailed(string reason);

    constructor() ERC721("Score NFT", "SNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setTreasury(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

  
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
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
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
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}