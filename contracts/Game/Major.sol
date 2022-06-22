// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
interface ERC20{
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}
/**
   * @title Major
   * @dev Game contract
   * @custom:dev-run-script browser/scripts/deploy_web3.js
    */
contract Major {
    address owner;
    ERC20 TOKEN;
    ERC20 RUBY;
    ERC20 SAPPHIRE;
    ERC20 EMERALD;

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
        uint8[] numbersOfRemaingEnemy;
        uint8[] numbersOfOriginEnemy;
        uint8[] numbersOfEnemyOnSingleDungeon;
    }
    struct DropsInfo {
        uint exp;
        ERC20[] typesOfMaterial;
        uint[] basesOfMaterial;
    }
    struct MaterialInfo {
        uint baseOfAbility;
    }

    mapping(address => bool) private isInit;
    mapping(address => Ability) private ability;
    mapping(address => Equipment) private equipment;
    mapping(address => PlayerStatus) private playerStatus;
    uint private seed;
    Dungeon[] private dungeon;
    uint8 public dungeonSize = 0;
    uint private timestamp;
    uint private interval = 30 seconds;//30 seconds for testing
    DropsInfo[] private dropsInfo;
    constructor(address _token, address _ruby, address _sapphire, address _emerald) {
        TOKEN = ERC20(_token);
        RUBY = ERC20(_ruby);
        SAPPHIRE = ERC20(_sapphire);
        EMERALD = ERC20(_emerald);
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


    function playerStatusOf(address _account) external view returns(string memory name, uint8 level, uint experience, uint distributableAbility) {
        PlayerStatus memory _playerStatus = playerStatus[_account];
        name = _playerStatus.name;
        level = _playerStatus.level;
        experience = _playerStatus.experience;
        distributableAbility = _playerStatus.distributableAbility;
    }

    function abilityOf(address _account) external view returns(uint str, uint intllegence, uint dex,uint vit, uint luk) {
        Ability memory _ability = ability[_account];
        str = _ability.str;
        intllegence = _ability.intllegence;
        dex = _ability.dex;
        vit = _ability.vit;
        luk = _ability.luk;
    }

    function dungeonOf(uint _indexOfDungeon) external view returns(uint cost, uint8[] memory numbersOfRemaingEnemy, uint8[] memory numbersOfOriginEnemy, uint8[] memory numbersOfEnemyOnSingleDungeon) {
        Dungeon memory _dungeon = dungeon[_indexOfDungeon];
        cost = _dungeon.cost;
        numbersOfRemaingEnemy = _dungeon.numbersOfRemaingEnemy;
        numbersOfOriginEnemy = _dungeon.numbersOfOriginEnemy;
        numbersOfEnemyOnSingleDungeon = _dungeon.numbersOfEnemyOnSingleDungeon;
    }

    function init(string memory _name) external {
        require(isInited(msg.sender) == false, "The account had been inited");
        isInit[msg.sender] = true;
        _updatePlayerStatus(PlayerStatus(_name, 0, 0, 0, 0, 0));
        _updateAbility(Ability(10, 10, 10, 10, 10));

        //test statement
        _updateEquipment(Equipment(1, 2, 3, 4, 10));
    }

    function enterDungeon(uint _indexOfDungeon) external {
        //boundary check
        require(_indexOfDungeon < dungeonSize, "Size Limit Exceeded");

        Dungeon memory _dungeon = dungeon[_indexOfDungeon];
        PlayerStatus memory _playerStatus = playerStatus[msg.sender];
        uint currentTime = block.timestamp;

        //reset the content of dungeon for each 12 hours
        if(currentTime >= timestamp + interval) {
            for(uint i = 0; i < _dungeon.numbersOfRemaingEnemy.length; i++) {
                _dungeon.numbersOfRemaingEnemy[i] = _dungeon.numbersOfOriginEnemy[i];
            }
        }

        //remaing check
        require(_dungeon.numbersOfRemaingEnemy[0] >= _dungeon.numbersOfEnemyOnSingleDungeon[0], "Not Enough Enemy");
        
        //transfer the entrance fee
        TOKEN.transferFrom(msg.sender, address(this), _dungeon.cost);

        //reduce the remaing enemy
        for(uint i = 0; i < _dungeon.numbersOfRemaingEnemy.length; i++) {
            _dungeon.numbersOfRemaingEnemy[i] -= _dungeon.numbersOfEnemyOnSingleDungeon[i];
        }

        //update the playerStatus about dungeon
        _playerStatus.siteOfDungeon = _indexOfDungeon;
        _playerStatus.timestamp = currentTime;

        //write back
        _updateDungeon(_indexOfDungeon, _dungeon);
        _updatePlayerStatus(_playerStatus);

    }

    function exchangeMaterial(uint8[] memory _drops) external {
        for(uint i = 0; i < _drops.length; i++) {
            DropsInfo memory _dropsInfo = dropsInfo[_drops[i]];
            for(uint j = 0; j < _dropsInfo.typesOfMaterial.length; j++) {
                require(_dropsInfo.typesOfMaterial[j].balanceOf(address(this)) 
                > _dropsInfo.basesOfMaterial[j], "Not enough material");
                
                //determine the finalAmount by luk of this player
                Ability memory _ability = ability[msg.sender];
                uint finalAmount = _dropsInfo.basesOfMaterial[j] 
                + ((_ability.luk > _random(seed) % 1001) ? _dropsInfo.basesOfMaterial[j] / 2 : 0);
                
                _dropsInfo.typesOfMaterial[j].transfer(msg.sender, finalAmount);
            }
        }
    }
 
    function createDungeon(uint _cost, uint8[] memory _numbersOfOriginEnemy, uint8[] memory _numbersOfEnemyOnSingleDungeon) external onlyOwner {
        dungeon.push(Dungeon(_cost, _numbersOfOriginEnemy, _numbersOfOriginEnemy, _numbersOfEnemyOnSingleDungeon));
        dungeonSize++;
    }

    function createDropsInfo(uint _exp, uint8[] memory _typesOfMaterial, uint[] memory _basesOfMaterial) external onlyOwner {
        ERC20[] memory tempOfTypes = new ERC20[](_typesOfMaterial.length);
        for(uint i = 0; i < _typesOfMaterial.length; i++) {
            if(_typesOfMaterial[i] == 0) {
                tempOfTypes[i] = RUBY;
            }
            else if(_typesOfMaterial[i] == 1) {
                tempOfTypes[i] = SAPPHIRE;
            }
            else if(_typesOfMaterial[i] == 2) {
                tempOfTypes[i] = EMERALD;
            }
        }
        dropsInfo.push(DropsInfo(_exp, tempOfTypes, _basesOfMaterial));
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
  
    function _updateEquipment(Equipment memory _equipment) internal {
        equipment[msg.sender] = _equipment;
    }

    function _updateDungeon(uint _indexOfDungeon, Dungeon memory _dungeon) internal {
        dungeon[_indexOfDungeon] = _dungeon;
    }


}
