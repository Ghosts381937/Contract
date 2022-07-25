const CURRENCY = artifacts.require("Currency");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");
const MAJOR = artifacts.require("Major");
const RUBY = artifacts.require("Ruby");
const SAPPHIRE = artifacts.require("Sapphire");
const EMERALD = artifacts.require("Emerald");

const COUNT_OF_DUNGEON_INFO = 4;
const COUNT_OF_PLAYER_STATUS = 5;

const parseObejectToAssertedForm = (returnObject, len) => {
  for(let i = 0; i < len; i++) {
    delete returnObject[i];
  }
  let objectKeys = Object.keys(returnObject);
  objectKeys.forEach((key) => {
    returnObject[key] = returnObject[key].toString();
  })
  return returnObject;
}

const getRandomInt = (max) => {
  return Math.floor(Math.random() * max);
}

contract("CURRENCY", (accounts) => {
  //functional test
  it("should put 10^22 TFToken in the first account", async() => {
    const currency = await CURRENCY.deployed();
    const balance = await currency.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("RUBY", (accounts) => {
  //functional test
  it("should put 10^22 RUBY in the first account", async() => {
    const ruby = await RUBY.deployed();
    const balance = await ruby.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("SAPPHIRE", (accounts) => {
  //functional test
  it("should put 10^22 SAPPHIRE in the first account", async() => {
    const sapphire = await SAPPHIRE.deployed();
    const balance = await sapphire.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("EMERALD", (accounts) => {
  //functional test
  it("should put 10^22 EMERALD in the first account", async() => {
    const emerald = await EMERALD.deployed();
    const balance = await emerald.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("NFT", () => {
  //functional test
  it("should be 'Test' in the [name]", async() => {
    const nft = await NFT.deployed()
    const name = await nft.name.call();
    assert.equal(name, 'Test', "'Test' wasn't in the [name]");
  });
  it("should be MARKET.address in the [specificContract]", async() => {
    const nft = await NFT.deployed()
    const address = await nft.specificContract.call();
    assert.equal(address, MARKET.address, "'MARKET.address' wasn't in the [specificContract]");
  });
});
contract("MAJOR", (accounts) => {
  //functional test
  it("init()", async() => {
    const major = await MAJOR.deployed();
    let expectedName = "testName";
    let expectedIsinited = true;
    let expectedPlayerStatus = {name:expectedName, level:"1", experience: "0", distributableAbility: "0", siteOfDungeon: "0"};
    let expectedAbility = {str: "10", intllegence: "10", dex: "10", vit: "10", luk: "10"};
    let expectedEquipment = {helmet: "1", chestplate: "2", leggings: "3", boots: "4", weapon: "10"}
    await major.init(expectedName, {from:accounts[0]});
    
    let actualIsinited = await major.isInited.call(accounts[0]);
    let actualPlayerStatus = await major.playerStatusOf.call(accounts[0]);
    actualPlayerStatus = parseObejectToAssertedForm(actualPlayerStatus, Object.keys(expectedPlayerStatus).length);
    let actualAbility = await major.abilityOf.call(accounts[0]);
    actualAbility = parseObejectToAssertedForm(actualAbility, Object.keys(expectedAbility).length);
    let actualEquipment = await major.equipmentOf.call(accounts[0]);
    actualEquipment = parseObejectToAssertedForm(actualEquipment, Object.keys(expectedEquipment).length);

    
    assert.deepEqual(expectedIsinited, actualIsinited, "isInited was not successfully alterd");
    assert.deepEqual(expectedPlayerStatus, actualPlayerStatus, "playerStatus was not successfully alterd");
    assert.deepEqual(expectedAbility, actualAbility, "ability was not successfully alterd");
    assert.deepEqual(expectedEquipment, actualEquipment, "equipment was not successfully alterd");
  });

  it("createDungeon()", async() => {
    //functional test
    const major = await MAJOR.deployed();
    let expectedDungeons = [{
        cost: web3.utils.toWei('10', 'ether'), 
        numbersOfRemaingEnemy: ["100", "100"], 
        numbersOfOriginEnemy: ["100", "100"], 
        numbersOfEnemyOnSingleDungeon: ["10", "10"]
      }, {
        cost: web3.utils.toWei('20', 'ether'), 
        numbersOfRemaingEnemy: ["200", "50"], 
        numbersOfOriginEnemy: ["200", "50"], 
        numbersOfEnemyOnSingleDungeon: ["20", "5"]
      }, {
        cost: web3.utils.toWei('30', 'ether'), 
        numbersOfRemaingEnemy: ["250", "60", "30"], 
        numbersOfOriginEnemy: ["250", "60", "30"], 
        numbersOfEnemyOnSingleDungeon: ["25", "6", "3"]
      }, {
        cost: web3.utils.toWei('40', 'ether'), 
        numbersOfRemaingEnemy: ["120", "70", "40", "10"], 
        numbersOfOriginEnemy: ["120", "70", "40", "10"], 
        numbersOfEnemyOnSingleDungeon: ["12", "7", "4", "1"]
      }, 
    ];
    const DUNGEON_INFO_SIZE = Object.keys(expectedDungeons[0]).length;
    for(let index = 0; index < DUNGEON_INFO_SIZE; index++) {
      let expectedDungeon = expectedDungeons[index];
      await major.createDungeon(expectedDungeon.cost, expectedDungeon.numbersOfOriginEnemy, expectedDungeon.numbersOfEnemyOnSingleDungeon, {from:accounts[0]});
      let actualDungeon = parseObejectToAssertedForm(await major.dungeonOf.call(index), DUNGEON_INFO_SIZE);
      expectedDungeon = parseObejectToAssertedForm(expectedDungeon, DUNGEON_INFO_SIZE);
      assert.deepEqual(expectedDungeon, actualDungeon);
    }
  });

  it("enterDungeon()", async() => {
    //boundary test
    const major = await MAJOR.deployed();
    const currency = await CURRENCY.deployed();

    //approve the currency for major
    await currency.approve(MAJOR.address, web3.utils.toWei('99999', 'ether'), {from:accounts[0]});
    
    let dungeonSize = await major.dungeonSize.call();
    let min = 0;
    let max = dungeonSize - 1;
    let normal = getRandomInt(dungeonSize);

    //test for out of bounds
    let expectedReason = "value out-of-bounds";
    try {
      await major.enterDungeon(min - 1, {from:accounts[0]});
    } catch(e) {
      let actualReason = e.reason;
      assert.equal(expectedReason, actualReason)
    }
    try {
      await major.enterDungeon(max - 1, {from:accounts[0]});
    } catch(e) {
      let actualReason = e.reason;
      assert.equal(expectedReason, actualReason)
    }

    //others
    let otherCases = [min, min + 1, normal, max - 1, max];
    for(let i = 0; i < otherCases.length; i++) {
      let case_ = otherCases[i];

      //expected data
      let expectedPlayerStatus = await major.playerStatusOf.call(accounts[0]);
      expectedPlayerStatus.siteOfDungeon = case_;
      expectedPlayerStatus = parseObejectToAssertedForm(expectedPlayerStatus, COUNT_OF_PLAYER_STATUS);
      let expectedDungeon = await major.dungeonOf.call(case_);
      for(let i = 0; i < expectedDungeon.numbersOfRemaingEnemy.length; i++) {
        expectedDungeon.numbersOfRemaingEnemy[i] -= expectedDungeon.numbersOfEnemyOnSingleDungeon[i];
      }
      expectedDungeon = parseObejectToAssertedForm(expectedDungeon, COUNT_OF_DUNGEON_INFO);

      await major.enterDungeon(case_, {from:accounts[0]});

      //actual data
      let actualPlayerStatus = await major.playerStatusOf.call(accounts[0]);
      actualPlayerStatus = parseObejectToAssertedForm(actualPlayerStatus, COUNT_OF_PLAYER_STATUS);
      let actualDungeon = await major.dungeonOf.call(case_);
      actualDungeon = parseObejectToAssertedForm(actualDungeon, COUNT_OF_DUNGEON_INFO);

      assert.deepEqual(expectedPlayerStatus, actualPlayerStatus, "playerStatus was not successfully alterd");
      assert.deepEqual(expectedDungeon, actualDungeon, "dungeon was not successfully alterd");
    }
  });
});