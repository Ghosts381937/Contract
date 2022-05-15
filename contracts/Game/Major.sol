// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
interface ERC20{
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
}
contract Major {
    address owner;
    uint8 constant NUMBERS_OF_SKILL = 8;
    ERC20 constant TOKEN = ERC20(0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c);
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
        uint8[] typesOfEnemy;
        uint8[] numbersOfRemaingEnemy;
        uint8[] numbersOfOriginEnemy;
        uint8[] numbersOfEnemyOnSingleDungeon;
        uint8[] typesOfTreasure;
        uint8[] numbersOfRemaingTreasure;
        uint8[] numbersOfOriginTreasure;
        uint8[] maxNumbersOfTreasureOnSingleDungeon;
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
    Dungeon[] private dungeon;
    uint8 private dungeonSize = 0;
    uint private timestamp;

    constructor() {
        owner = msg.sender;
        timestamp = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied.");
        _;
    }

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

    function enterDungeon(uint _indexOfDungeon) external {
        require(_indexOfDungeon < dungeonSize, "Size Limit Exceeded");
        Dungeon memory _dungeon = dungeon[_indexOfDungeon];

        if(block.timestamp >= timestamp + 12 hours) {//reset the content of dungeon for each 12 hours
            _dungeon.numbersOfRemaingEnemy = _dungeon.numbersOfOriginEnemy;
            _dungeon.numbersOfRemaingTreasure = _dungeon.numbersOfOriginTreasure;
        }

        require(_dungeon.numbersOfRemaingEnemy[0] >= _dungeon.numbersOfEnemyOnSingleDungeon[0], "Not Enough Enemy");
        TOKEN.transferFrom(msg.sender, address(this), _dungeon.cost);
    
    }

    function createDungeon(uint _cost, uint8[] memory _typesOfEnemy, uint8[] memory _numbersOfOriginEnemy, uint8[] memory _numbersOfEnemyOnSingleDungeon, uint8[] memory _typesOfTreasure, uint8[] memory _numbersOfOriginTreasure, uint8[] memory _maxNumbersOfTreasureOnSingleDungeon) external onlyOwner {
        dungeon.push(Dungeon(_cost, _typesOfEnemy, _numbersOfOriginEnemy, _numbersOfOriginEnemy, _numbersOfEnemyOnSingleDungeon, _typesOfTreasure, _numbersOfOriginTreasure, _numbersOfOriginTreasure, _numbersOfOriginTreasure));
        dungeonSize++;
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
