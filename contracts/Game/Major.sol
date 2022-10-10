// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

interface ERC20 {
    function transferFrom(
        address from,
        address to,
        
        uint256 amount
    ) external;

    function transfer(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

interface ERC721 {
    function createNFT(
        address _player, string memory _tokenURI
    ) external returns (uint256);

    function ownerOf(uint256 tokenId) external returns (address);

    function burn(uint256 tokenId) external;
}

interface TokenURI {
    function get(uint part, uint index) external returns(string memory tokenURI);
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
    ERC721 NFT;
    TokenURI tokenURI;
    uint256 TOKEN_DECIMAL = 1e18;
    uint256 PROBABILITY_OF_C = 55 * 20; //55%
    uint256 PROBABILITY_OF_U = 30 * 20; //30%
    uint256 PROBABILITY_OF_R = 10 * 20; //10%
    uint256 PROBABILITY_OF_L = 5 * 20; //5%
    uint8 TOTAL_COMBINATION_OF_SKILL_ON_U = 2;
    uint8 TOTAL_COMBINATION_OF_SKILL_ON_R = 2;
    uint8 TOTAL_COMBINATION_OF_SKILL_ON_L = 2;
    uint16[4] MAX_OFFEST_OF_ATTRIBUTE = [99, 899, 3999, 4999];
    uint16[4] MIN_ATTRIBUTE = [1, 101, 1001, 5001];
    uint8[4] MAX_CRI_DMG_RATIO = [5, 10, 15, 20]; //20%
    uint8[4] PROBABILITY_OF_CRI_DMG_RATIO = [55, 27, 13, 4]; //55% to get 1~5% criDmgRatio, 27% to get 6~10% criDmgRatio, and so on.
    uint8 LOSS_RATE = 3; //30% to loss
    uint8 INITIAL_LEVEL = 1;
    uint8 MAX_LEVEL = 100;
    uint16[3] CONST_EXP = [100, 150, 200];
    uint16 LINEAR_EXP_LEVEL = 31;
    uint16 LINEAR_EXP_BASE = 300;
    uint16 LINEAR_EXP_RATIO = 2;
    uint16[2] LINEAR_EXP_FACTOR = [10, 5];//10% for lv31 ~ 90, 5% for lv 91 ~ 100

    struct Ability {
        uint256 str;
        uint256 intllegence;
        uint256 dex;
        uint256 vit;
        uint256 luk;
    }
    struct Equipment {
        uint256 helmet;
        uint256 chestplate;
        uint256 leggings;
        uint256 boots;
        uint256 weapon;
    }
    struct PlayerStatus {
        string name;
        uint8 level;
        uint256 experience;
        uint256 distributableAbility;
        uint256 siteOfDungeon;
        uint256 timestamp;
    }
    struct Dungeon {
        uint256 cost;
        uint8[] numbersOfRemaingEnemy;
        uint8[] numbersOfOriginEnemy;
        uint8[] numbersOfEnemyOnSingleDungeon;
    }
    struct DropsInfo {
        uint256 exp;
        address[] typesOfMaterial;
        uint256[] basesOfMaterial;
    }
    struct MaterialInfo {
        uint256 baseOfAbility;
    }

    mapping(address => bool) private isInit;
    mapping(address => Ability) private ability;
    mapping(address => Equipment) private equipment;
    mapping(address => PlayerStatus) private playerStatus;
    uint256 private seed = 0;
    Dungeon[] private dungeon;
    uint8 public dungeonSize = 0;
    uint256 private timestamp;
    uint256 private interval = 30 seconds; //30 seconds for testing
    DropsInfo[] public dropsInfo;

    constructor(
        address _token,
        address _nft,
        address _ruby,
        address _sapphire,
        address _emerald,
        address _tokenURI
    ) {
        TOKEN = ERC20(_token);
        NFT = ERC721(_nft);
        RUBY = ERC20(_ruby);
        SAPPHIRE = ERC20(_sapphire);
        EMERALD = ERC20(_emerald);
        tokenURI = TokenURI(_tokenURI);
        owner = msg.sender;
        timestamp = block.timestamp;
    }

    event Equip(Equipment indexed oldEquipment, Equipment indexed newEquipment);
    event Test(uint a, uint b);

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied.");
        _;
    }

    function isInited(address _account) public view returns (bool) {
        return isInit[_account];
    }

    function equipmentOf(address _account)
        external
        view
        returns (
            uint256 helmet,
            uint256 chestplate,
            uint256 leggings,
            uint256 boots,
            uint256 weapon
        )
    {
        Equipment memory _equipment = equipment[_account];
        helmet = _equipment.helmet;
        chestplate = _equipment.chestplate;
        leggings = _equipment.leggings;
        boots = _equipment.boots;
        weapon = _equipment.weapon;
    }

    function playerStatusOf(address _account)
        external
        view
        returns (
            string memory name,
            uint8 level,
            uint256 experience,
            uint256 distributableAbility,
            uint256 siteOfDungeon
        )
    {
        PlayerStatus memory _playerStatus = playerStatus[_account];
        name = _playerStatus.name;
        level = _playerStatus.level;
        experience = _playerStatus.experience;
        distributableAbility = _playerStatus.distributableAbility;
        siteOfDungeon = _playerStatus.siteOfDungeon;
    }

    function abilityOf(address _account)
        external
        view
        returns (
            uint256 str,
            uint256 intllegence,
            uint256 dex,
            uint256 vit,
            uint256 luk
        )
    {
        Ability memory _ability = ability[_account];
        str = _ability.str;
        intllegence = _ability.intllegence;
        dex = _ability.dex;
        vit = _ability.vit;
        luk = _ability.luk;
    }

    function dungeonOf(uint256 _indexOfDungeon)
        external
        view
        returns (
            uint256 cost,
            uint8[] memory numbersOfRemaingEnemy,
            uint8[] memory numbersOfOriginEnemy,
            uint8[] memory numbersOfEnemyOnSingleDungeon
        )
    {
        Dungeon memory _dungeon = dungeon[_indexOfDungeon];
        cost = _dungeon.cost;
        numbersOfRemaingEnemy = _dungeon.numbersOfRemaingEnemy;
        numbersOfOriginEnemy = _dungeon.numbersOfOriginEnemy;
        numbersOfEnemyOnSingleDungeon = _dungeon.numbersOfEnemyOnSingleDungeon;
    }

    function dropsInfoOf(uint8 _index) external view returns(uint256 exp, address[] memory typesOfMaterial, uint256[] memory basesOfMaterial) {
        DropsInfo memory _dropsInfo = dropsInfo[_index];
        exp = _dropsInfo.exp;
        typesOfMaterial = _dropsInfo.typesOfMaterial;
        basesOfMaterial = _dropsInfo.basesOfMaterial;
    }

    function init(string memory _name) external {
        require(isInited(msg.sender) == false, "The account had been inited");
        isInit[msg.sender] = true;
        _updatePlayerStatus(PlayerStatus(_name, 1, 0, 0, 0, 0));
        _updateAbility(Ability(10, 10, 10, 10, 10));

        //test statement
        _updateEquipment(Equipment(1, 2, 3, 4, 10));
    }

    function enterDungeon(uint256 _indexOfDungeon) external {
        //boundary check
        require(_indexOfDungeon >= 0, "Out of bounds");
        require(_indexOfDungeon < dungeonSize, "Out of bounds");

        Dungeon memory _dungeon = dungeon[_indexOfDungeon];
        PlayerStatus memory _playerStatus = playerStatus[msg.sender];
        uint256 currentTime = block.timestamp;

        //reset the content of dungeon for each 12 hours
        if (currentTime >= timestamp + interval) {
            for (
                uint256 i = 0;
                i < _dungeon.numbersOfRemaingEnemy.length;
                i++
            ) {
                _dungeon.numbersOfRemaingEnemy[i] = _dungeon
                    .numbersOfOriginEnemy[i];
            }
        }

        //remaing check
        require(
            _dungeon.numbersOfRemaingEnemy[0] >=
                _dungeon.numbersOfEnemyOnSingleDungeon[0],
            "Not Enough Enemy"
        );

        //transfer the entrance fee
        TOKEN.transferFrom(msg.sender, address(this), _dungeon.cost);

        //reduce the remaing enemy
        for (uint256 i = 0; i < _dungeon.numbersOfRemaingEnemy.length; i++) {
            _dungeon.numbersOfRemaingEnemy[i] -= _dungeon
                .numbersOfEnemyOnSingleDungeon[i];
        }

        //update the playerStatus about dungeon
        _playerStatus.siteOfDungeon = _indexOfDungeon;
        _playerStatus.timestamp = currentTime;

        //write back
        _updateDungeon(_indexOfDungeon, _dungeon);
        _updatePlayerStatus(_playerStatus);
    }

    function exchangeMaterial(uint8[] memory _drops) external {
        for (uint256 i = 0; i < _drops.length; i++) {
            if(_drops[i] == 0) {
                continue;
            }
            DropsInfo memory _dropsInfo = dropsInfo[i];
            for (uint256 j = 0; j < _dropsInfo.typesOfMaterial.length; j++) {
                require(
                    ERC20(_dropsInfo.typesOfMaterial[j]).balanceOf(address(this)) >
                        (_dropsInfo.basesOfMaterial[j] * _drops[i]) / 4 * 7,//*1.75
                    "Not enough material"
                );

                //determine the finalAmount with luk of this player
                Ability memory _ability = ability[msg.sender];
                uint256 finalAmount = _dropsInfo.basesOfMaterial[j] * _drops[i] +
                    (
                        (_ability.luk > _random(seed) % 1001)
                            ? _dropsInfo.basesOfMaterial[j] / 2
                            : 0
                    );
                ERC20(_dropsInfo.typesOfMaterial[j]).transfer(msg.sender, finalAmount);
            }
            _gainExp(_dropsInfo.exp * _drops[i]);
        }
    }

    function createDungeon(
        uint256 _cost,
        uint8[] memory _numbersOfOriginEnemy,
        uint8[] memory _numbersOfEnemyOnSingleDungeon
    ) external onlyOwner {
        dungeon.push(
            Dungeon(
                _cost,
                _numbersOfOriginEnemy,
                _numbersOfOriginEnemy,
                _numbersOfEnemyOnSingleDungeon
            )
        );
        dungeonSize++;
    }

    function createDropsInfo(
        uint256 _exp,
        address[] memory _typesOfMaterial,
        uint256[] memory _basesOfMaterial
    ) external onlyOwner {
        dropsInfo.push(DropsInfo(_exp, _typesOfMaterial, _basesOfMaterial));
    }

    function forge(
        uint8 _part,
        uint16 _amountOfRuby,
        uint16 _amountOfSapphire,
        uint16 _amountOfEmerald
    ) external {
        require(_amountOfRuby <= 200, "Too Many Ruby");
        require(_amountOfSapphire <= 200, "Too Many Sapphire");
        require(_amountOfEmerald <= 200, "Too Many Emerald");
        require(_part <= 4, "Too Many Part");
        
        uint256 sumOfAmount = _amountOfRuby +
            _amountOfSapphire +
            _amountOfEmerald;
        require(sumOfAmount >= 50, "Not Enough Materials");

        //Transfer the materials
        uint256 tokenDecimal = TOKEN_DECIMAL;
        RUBY.transferFrom(
            msg.sender,
            address(this),
            _amountOfRuby * tokenDecimal
        );
        SAPPHIRE.transferFrom(
            msg.sender,
            address(this),
            _amountOfSapphire * tokenDecimal
        );
        EMERALD.transferFrom(
            msg.sender,
            address(this),
            _amountOfEmerald * tokenDecimal
        );

        //determine the attribute of a nft.
        uint256 randomNumber = _random(seed) % 2000 + 1;
        uint rarity = _rollRarity(sumOfAmount, randomNumber);
        string memory tokenURI_;
        tokenURI_ = tokenURI.get(_part, rarity + randomNumber % 2);

        NFT.createNFT(msg.sender,tokenURI_);
    }

    function distributeAbility(uint256 _str,uint256 _intllegence,uint256 _dex,uint256 _vit,uint256 _luk) external {
        Ability memory _ability;
        _ability = ability[msg.sender];
        PlayerStatus memory _playerStatus;
        _playerStatus = playerStatus[msg.sender];
        uint256 sumOfAbility = _ability.str + _ability.intllegence + _ability.dex + _ability.vit + _ability.luk;
        uint256 sumOfNewAbility = _str + _intllegence + _dex + _vit + _luk;

        require(_str >= _ability.str && _intllegence >= _ability.intllegence &&
                _dex >= _ability.dex && _vit >= _ability.vit && _luk >= _ability.luk, "New ability is less than current ability");
        require(_playerStatus.distributableAbility >= sumOfNewAbility - sumOfAbility, "Too many distributableAbility");
    
        _playerStatus.distributableAbility -= sumOfNewAbility - sumOfAbility;
        _ability.str = _str;
        _ability.intllegence = _intllegence;
        _ability.dex = _dex;
        _ability.vit = _vit;
        _ability.luk = _luk;

        _updatePlayerStatus(_playerStatus);
        _updateAbility(_ability);
    }

    function equip(uint256 _helmet, uint256 _chestplate, uint256 _leggings, uint256 _boots, uint256 _weapon) external {
        require(
            (_helmet == 0 || NFT.ownerOf(_helmet) == msg.sender) &&
            (_chestplate == 0 || NFT.ownerOf(_chestplate) == msg.sender) &&
            (_leggings == 0 || NFT.ownerOf(_leggings) == msg.sender) &&
            (_boots == 0 || NFT.ownerOf(_boots) == msg.sender) &&
            (_weapon ==0 || NFT.ownerOf(_weapon) == msg.sender)
            , "You are not the owner.");

        Equipment memory newEquipment = Equipment(_helmet, _chestplate, _leggings, _boots, _weapon);
        _updateEquipment(newEquipment);
        emit Equip(equipment[msg.sender], newEquipment);
    }

    function destroyEquipment(uint256 _tokenId) external {
        NFT.burn(_tokenId);
    }

    function _random(uint256 _seed) internal view returns (uint256) {
        uint256 seed_temp = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), _seed))
        );
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

    function _updateDungeon(uint256 _indexOfDungeon, Dungeon memory _dungeon)
        internal
    {
        dungeon[_indexOfDungeon] = _dungeon;
    }

    function _rollRarity(uint256 sumOfAmount, uint256 randomNumber)
        internal
        view
        returns (uint8 rarity)
    {
        //Determine the rarity
        uint256 probabilityOfC = PROBABILITY_OF_C;
        uint256 probabilityOfU = PROBABILITY_OF_U;
        uint256 probabilityOfR = PROBABILITY_OF_R;
        uint256 probabilityOfL = PROBABILITY_OF_L;
        uint256 offest = (sumOfAmount - 300);
        probabilityOfC -= offest << 1;
        probabilityOfU +=
            (offest > 100 ? 10 * 20 : offest << 1) +
            (offest > 200 ? 5 * 20 : (offest > 100 ? (offest - 100) : 0));
        probabilityOfR += offest <= 100 ? 0 : (offest - 100);
        probabilityOfL += offest <= 200 ? 0 : (offest - 200);
        
        if (randomNumber <= probabilityOfC) {
            rarity = 0;
        } else if (randomNumber <= probabilityOfC + probabilityOfU) {
            rarity = 2;
        } else if (randomNumber <= probabilityOfC + probabilityOfU + probabilityOfR) {
            rarity = 4;
        } else if (randomNumber <= probabilityOfC + probabilityOfU + probabilityOfR + probabilityOfL) {
            rarity = 6;
        }
    }

    function _gainExp(uint256 _getExp) internal {
        PlayerStatus memory playerStatus_ = playerStatus[msg.sender];
        uint8 level = playerStatus_.level;
        uint256 exp = playerStatus_.experience;
        
        // uint256 levelUpGap = LINEAR_EXP_BASE * (2 * 10 + ((MAX_LEVEL - LINEAR_EXP_LEVEL) * 10 / 5)) / 10; //Using mut10 to prevent the floating point number

        // if(level <= 10) {
        //     levelUpGap = CONST_EXP[0];
        // }
        // else if(level > 10 && level <= 20) {
        //     levelUpGap = CONST_EXP[1];
        // }
        // else if(level > 20 && level <= 30) {
        //     levelUpGap = CONST_EXP[2];
        // }
        // else if(level > 30 && level <= 90) {
        //     levelUpGap = LINEAR_EXP_BASE * (2 * 10 + ((MAX_LEVEL - LINEAR_EXP_LEVEL) * 10 / LINEAR_EXP_FACTOR[0])) / 10; //Using mut10 to prevent the floating point number
        // }
        // else if(level > 90 && level <= 100) {
        //     levelUpGap = levelUpGap;
        // }
        exp += _getExp;
        uint8 newLevel = uint8(exp / 100 + 1);
        playerStatus_.distributableAbility += (newLevel - level) * 15;
        level = newLevel;
        playerStatus_.experience = exp;
        playerStatus_.level = level;
        emit Test(exp, _getExp);

        _updatePlayerStatus(playerStatus_);

    }
}
