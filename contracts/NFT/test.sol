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
    struct Attribute {
        uint16 atk;
        uint16 matk;
        uint16 def;
        uint16 mdef;
        uint16 cri;
        uint16 criDmgRatio;
    }
    struct TokenStat {
        uint8 rarity;
        uint8 part;
        uint8 level;
        Attribute attribute;
        uint8[3] skills;
    }
    string constant public NAME = "Test";
    string constant public SYMBOL = "T";
    address public specificContract;
    Counters.Counter private _tokenIds;
    address public owner;
    mapping(uint => TokenStat) private tokenStats;

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

    function tokenStatOf(uint _tokenId) external view returns(uint8 rarity, uint8 part, uint8 level, Attribute memory attribute, uint8[3] memory skills) {
        TokenStat memory _tokenStat = tokenStats[_tokenId];
        rarity = _tokenStat.rarity;
        part = _tokenStat.part;
        level = _tokenStat.level;
        attribute = _tokenStat.attribute;
        skills = _tokenStat.skills;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        delete tokenStats[tokenId];
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

    function createNFT(address _player, string memory _tokenURI) external returns(uint) {
        _tokenIds.increment();

        uint256 _newItemId = _tokenIds.current();
        _mint(_player, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);
        // Attribute memory _attribute = Attribute(_atk, _matk, _def, _mdef, _cri, _criDmgRatio);
        // _setTokenStat(_rarity, _part, _level, _attribute, _skills, _newItemId);
        return _newItemId;
    }

    function setSpecificContract(address _contract) onlyOwner external {
        specificContract = _contract;
    }

    function _setTokenStat(uint8 _rarity, uint8 _part, uint8 _level, Attribute memory _attribute, uint8[3] memory _skills,uint _newItemId) internal {
        tokenStats[_newItemId] = TokenStat(_rarity, _part, _level, _attribute, _skills);
    }
}