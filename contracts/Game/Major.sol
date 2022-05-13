// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract Major {

    uint8 constant NUMBERS_OF_SKILL = 8;
    struct Ability {
        uint str;
        uint intllegence;
        uint dex;
        uint vit;
        uint luk;
    }
    struct Equipment {
        uint helmet;
        uint chestplate;
        uint leggings;
        uint boots;
        uint weapon;
    }
    struct PlayerStatus {
        string name;
        uint8 level;
        uint experience;
        uint distributableAbility;
        uint siteOfDungeon;
        uint timestamp;
    }
    struct Dungeon {
        uint cost;
        uint[] typesOfEnemy;
        uint[] numbersOfRemaingEnemy;
        uint[] typesOfTreasure;
        uint[] numbersOfRemaingTreasure;
    }
    struct DropsInfo {
        uint[] typesOfMaterial;
        uint[] basesOfMaterial;
    }
    struct MaterialInfo {
        uint numbersOfRemaing;
        uint baseOfAbility;
    }

    mapping(address => bool) private isInit;
    mapping(address => Ability) private ability;
    mapping(address => uint8[NUMBERS_OF_SKILL]) private skill;
    mapping(address => Equipment) private equipment;
    mapping(address => PlayerStatus) private playerStatus;

    function isInited(address _account) public view returns(bool) {
        return isInit[_account];
    }

    function equipmentOf(address _account) external view returns(uint helmet, uint chestplate, uint leggings, uint boots, uint weapon) {
        Equipment memory _equipment = equipment[_account];
        helmet = _equipment.helmet;
        chestplate = _equipment.chestplate;
        leggings = _equipment.leggings;
        boots = _equipment.boots;
        weapon = _equipment.weapon;
    }

    function skillOf(address _account) external view returns(uint8[NUMBERS_OF_SKILL] memory skills) {
        skills = skill[_account];
    }

    function playerStatusOf(address _account) external view returns(string memory name, uint8 level, uint experience, uint distributableAbility) {
        PlayerStatus memory _playerStatus = playerStatus[_account];
        name = _playerStatus.name;
        level = _playerStatus.level;
        experience = _playerStatus.experience;
        distributableAbility = _playerStatus.distributableAbility;
    }

    function abilityOf(address _account) external view returns(uint str, uint intllegence, uint dex, uint luk) {
        Ability memory _ability = ability[_account];
        str = _ability.str;
        intllegence = _ability.intllegence;
        dex = _ability.dex;
        luk = _ability.luk;
    }

    function init(string memory _name) external {
        require(isInited(msg.sender) == false, "The account had been inited");
        isInit[msg.sender] = true;
        _updatePlayerStatus(PlayerStatus(_name, 0, 0, 0, 0, 0));
        _updateAbility(Ability(10, 10, 10, 10, 10));

        //test statement
        _updateEquipment(Equipment(1, 2, 3, 4, 10));
        uint8[NUMBERS_OF_SKILL] memory _skill = [1, 0, 1, 1, 0, 1, 0, 0];
        _updateSkill(_skill);
    }
    
    function _random(uint256 _seed) internal view returns(uint){
        uint seed_temp =  uint(keccak256(abi.encodePacked(blockhash(block.number - 1), _seed)));
        return seed_temp;
    }

    function _updatePlayerStatus(PlayerStatus memory _playerStatus) internal {
        playerStatus[msg.sender] = _playerStatus;
    }

    function _updateAbility(Ability memory _ability) internal {
        ability[msg.sender] = _ability;
    }

    function _updateSkill(uint8[NUMBERS_OF_SKILL] memory _skill) internal {
        skill[msg.sender] = _skill;
    }
  
    function _updateEquipment(Equipment memory _equipment) internal {
        equipment[msg.sender] = _equipment;
    }


}
