// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItem is ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
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
    mapping(uint => TokenStat) private tokenStats;

    constructor(address _specificContract) ERC721("Test", "T") {
        specificContract = _specificContract; 
    }

    address private specificContract;

    modifier onlySpecificContract() {
        require(msg.sender == specificContract, "You are not specificContract");
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

    function createNFT(address _player, uint8 _rarity, uint8 _part, uint8 _level, uint16 _atk, uint16 _matk, uint16 _def, uint16 _mdef, uint16 _cri, uint16 _criDmgRatio, uint8[3] memory _skills) external onlySpecificContract returns(uint) {
        _tokenIds.increment();

        uint256 _newItemId = _tokenIds.current();
        _mint(_player, _newItemId);
        Attribute memory _attribute = Attribute(_atk, _matk, _def, _mdef, _cri, _criDmgRatio);
        _setTokenStat(_rarity, _part, _level, _attribute, _skills, _newItemId);
        return _newItemId;
    }

    function _setTokenStat(uint8 _rarity, uint8 _part, uint8 _level, Attribute memory _attribute, uint8[3] memory _skills,uint _newItemId) internal {
        tokenStats[_newItemId] = TokenStat(_rarity, _part, _level, _attribute, _skills);
    }
}