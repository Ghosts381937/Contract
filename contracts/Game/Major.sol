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
        address _player,
        uint8 _rarity,
        uint8 _part,
        uint8 _level,
        uint16 _atk,
        uint16 _matk,
        uint16 _def,
        uint16 _mdef,
        uint16 _cri,
        uint16 _criDmgRatio,
        uint8[3] memory _skills
    ) external returns (uint256);
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
        ERC20[] typesOfMaterial;
        uint256[] basesOfMaterial;
    }
    struct MaterialInfo {
        uint256 baseOfAbility;
    }
    struct NFTInfo {
        uint8 rarity;
        uint16 atk;
        uint16 matk;
        uint16 def;
        uint16 mdef;
        uint16 cri;
        uint8 criDmgRatio;
        uint8[3] skills;
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
    DropsInfo[] private dropsInfo;

    constructor(
        address _token,
        address _nft,
        address _ruby,
        address _sapphire,
        address _emerald
    ) {
        TOKEN = ERC20(_token);
        NFT = ERC721(_nft);
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
            DropsInfo memory _dropsInfo = dropsInfo[_drops[i]];
            for (uint256 j = 0; j < _dropsInfo.typesOfMaterial.length; j++) {
                require(
                    _dropsInfo.typesOfMaterial[j].balanceOf(address(this)) >
                        _dropsInfo.basesOfMaterial[j],
                    "Not enough material"
                );

                //determine the finalAmount with luk of this player
                Ability memory _ability = ability[msg.sender];
                uint256 finalAmount = _dropsInfo.basesOfMaterial[j] +
                    (
                        (_ability.luk > _random(seed) % 1001)
                            ? _dropsInfo.basesOfMaterial[j] / 2
                            : 0
                    );
                seed = (seed + finalAmount) % type(uint192).max;
                _dropsInfo.typesOfMaterial[j].transfer(msg.sender, finalAmount);
            }
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
        uint8[] memory _typesOfMaterial,
        uint256[] memory _basesOfMaterial
    ) external onlyOwner {
        ERC20[] memory tempOfTypes = new ERC20[](_typesOfMaterial.length);
        for (uint256 i = 0; i < _typesOfMaterial.length; i++) {
            if (_typesOfMaterial[i] == 0) {
                tempOfTypes[i] = RUBY;
            } else if (_typesOfMaterial[i] == 1) {
                tempOfTypes[i] = SAPPHIRE;
            } else if (_typesOfMaterial[i] == 2) {
                tempOfTypes[i] = EMERALD;
            }
        }
        dropsInfo.push(DropsInfo(_exp, tempOfTypes, _basesOfMaterial));
    }

    function forge(
        uint8 _part,
        uint16 _amountOfRuby,
        uint16 _amountOfSapphire,
        uint16 _amountOfEmerald
    ) external returns (uint256) {
        uint256 sumOfAmount = _amountOfRuby +
            _amountOfSapphire +
            _amountOfEmerald;
        require(sumOfAmount >= 300, "Not Enough Materials");
        require(sumOfAmount <= 600, "Too Many Materials");

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

        //Parameter for createNFT()
        NFTInfo memory nftInfo;

        uint256 randomNumber = (_random(seed) % 2000) + 1;
        seed = (seed + randomNumber) % type(uint192).max;

        //Determine the nftInfo
        nftInfo.rarity = _rollRarity(sumOfAmount, randomNumber);
        nftInfo.skills = _rollSkills(nftInfo.rarity, randomNumber);
        (
            nftInfo.atk,
            nftInfo.def,
            nftInfo.matk,
            nftInfo.mdef,
            nftInfo.cri,
            nftInfo.criDmgRatio
        ) = _rollAttribute(
            randomNumber,
            _amountOfRuby,
            _amountOfSapphire,
            _amountOfEmerald,
            nftInfo.rarity,
            _part
        );

        uint256 tokenId = NFT.createNFT(
            msg.sender,
            nftInfo.rarity,
            _part,
            INITIAL_LEVEL,
            nftInfo.atk,
            nftInfo.matk,
            nftInfo.def,
            nftInfo.mdef,
            nftInfo.cri,
            nftInfo.criDmgRatio,
            nftInfo.skills
        );

        return tokenId;
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
        probabilityOfC -= offest << 2;
        probabilityOfU +=
            (offest > 100 ? 10 << 2 : offest << 2) +
            (offest > 200 ? 5 << 2 : (offest - 100));
        probabilityOfR += offest <= 100 ? 0 : (offest - 100);
        probabilityOfL += offest <= 200 ? 0 : (offest - 200);

        if (randomNumber <= probabilityOfC) {
            rarity = 0;
        } else if (randomNumber <= probabilityOfU) {
            rarity = 1;
        } else if (randomNumber <= probabilityOfR) {
            rarity = 2;
        } else if (randomNumber <= probabilityOfL) {
            rarity = 3;
        }
    }

    function _rollSkills(uint8 rarity, uint256 randomNumber)
        internal
        view
        returns (uint8[3] memory skills)
    {
        uint8 totalCombanationOfSkillOnU = TOTAL_COMBINATION_OF_SKILL_ON_U;
        uint8 totalCombanationOfSkillOnR = TOTAL_COMBINATION_OF_SKILL_ON_R;
        uint8 totalCombanationOfSkillOnL = TOTAL_COMBINATION_OF_SKILL_ON_L;
        if (rarity == 1) {
            skills[0] = uint8((randomNumber % totalCombanationOfSkillOnU) + 1);
            //[1], [2]
        } else if (rarity == 2) {
            skills[0] = uint8(
                (randomNumber % totalCombanationOfSkillOnR) +
                    totalCombanationOfSkillOnU +
                    1
            );
            skills[1] = skills[0] + totalCombanationOfSkillOnR;
            //[3, 5], [4, 6]
        } else if (rarity == 3) {
            skills[0] = uint8(
                (randomNumber % totalCombanationOfSkillOnL) +
                    totalCombanationOfSkillOnU +
                    totalCombanationOfSkillOnR *
                    2 +
                    1
            );
            skills[1] = skills[0] + totalCombanationOfSkillOnL;
            skills[2] = skills[1] + totalCombanationOfSkillOnL;
            //[7, 9, 11], [8, 10, 12]
        }
    }

    function _rollAttribute(
        uint256 randomNumber,
        uint16 _amountOfRuby,
        uint16 _amountOfSapphire,
        uint16 _amountOfEmerald,
        uint8 rarity,
        uint8 _part
    )
        internal
        view
        returns (
            uint16 atk,
            uint16 def,
            uint16 matk,
            uint16 mdef,
            uint16 cri,
            uint8 criDmgRatio
        )
    {
        //Determine the attribute
        //Max is 400 witch refers to 0% probability to forge a magical weapon.
        uint8 isMagic;
        {
            isMagic = ((randomNumber % 400) + 1) >
                (200 - _amountOfSapphire + _amountOfRuby)
                ? 1
                : 0;
        }

        uint8 lossRate;
        {
            lossRate = LOSS_RATE;
        }

        uint16 attribute;
        {
            attribute = _calculateAttribute(randomNumber, rarity);
        }

        {
            if (_part == 0) {
                //weapon
                atk = attribute * (isMagic ^ 1);
                def =
                    ((((attribute) * (isMagic ^ 1) * 10) / 10) * lossRate) /
                    10;
                matk = (attribute) * (isMagic);
                mdef = ((((attribute) * (isMagic) * 10) / 10) * lossRate) / 10;
                cri = ((attribute * 10) / 5 / 10 + _amountOfEmerald * 5) % 2001;
            } else if (_part > 0) {
                //equipment
                atk =
                    (((((attribute) * (isMagic ^ 1)) * 10) / 10) * lossRate) /
                    10;
                def =
                    (((((attribute) * (isMagic ^ 1)) * 10) / 10) *
                        (10 - _part)) /
                    10;
                matk =
                    (((((attribute) * (isMagic)) * 10) / 10) * lossRate) /
                    10;
                mdef =
                    (((((attribute) * (isMagic)) * 10) / 10) * (1 - _part)) /
                    10;
                cri = ((attribute * 10) / 5 / 10 + _amountOfEmerald * 5) % 2001;
            }
        }
        //Determine the criDmgRatio
        if (rarity >= 2) {
            criDmgRatio = _rollCriDmgRatio(randomNumber, _amountOfEmerald);
        }
    }

    function _calculateAttribute(uint256 randomNumber, uint8 rarity)
        internal
        view
        returns (uint16 attribute)
    {
        attribute = uint16(
            ((randomNumber + 3000) % MAX_OFFEST_OF_ATTRIBUTE[rarity]) +
                MIN_ATTRIBUTE[rarity]
        );
    }

    function _rollCriDmgRatio(uint256 randomNumber, uint16 _amountOfEmerald)
        internal
        view
        returns (uint8 criDmgRatio)
    {
        uint8[4] memory probabilityOfCriDmgRatio = PROBABILITY_OF_CRI_DMG_RATIO;
        randomNumber = (randomNumber % 100) + 1 + (_amountOfEmerald / 10);
        for (uint8 i = 0; i < 4; i++) {
            if (randomNumber <= probabilityOfCriDmgRatio[i]) {
                criDmgRatio = uint8((randomNumber % MAX_CRI_DMG_RATIO[i]) + 1);
                break;
            }
        }
    }
}
