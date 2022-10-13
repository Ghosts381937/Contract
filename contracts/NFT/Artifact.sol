// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nft is ERC721Enumerable, ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;
    string constant public NAME = "Artifact";
    string constant public SYMBOL = "AF";
    address public specificContract;
    Counters.Counter private _tokenIds;
    address public owner;
    mapping(uint => bool) private equipedTag;//it must be false when transferring  

    constructor() ERC721(NAME, SYMBOL) { 
        owner = msg.sender;
    }
    
    modifier onlySpecificContract() {
        require(msg.sender == specificContract, "You are not the specificContract");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        require(equipedTag[tokenId] == false, "Please take off your euqipment");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    function createNFT(address _player, string memory _tokenURI) onlySpecificContract external returns(uint) {
        _tokenIds.increment();

        uint256 _newItemId = _tokenIds.current();
        _mint(_player, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);
        setEquipedTag(_newItemId, false);
        // Attribute memory _attribute = Attribute(_atk, _matk, _def, _mdef, _cri, _criDmgRatio);
        // _setTokenStat(_rarity, _part, _level, _attribute, _skills, _newItemId);
        return _newItemId;
    }

    function setSpecificContract(address _contract) onlyOwner external {
        specificContract = _contract;
    }

    function setEquipedTag(uint tokenId, bool value) onlySpecificContract public {
        equipedTag[tokenId] = value;
    }
}