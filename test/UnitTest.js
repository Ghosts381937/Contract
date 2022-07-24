const CURRENCY = artifacts.require("Currency");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");
const MAJOR = artifacts.require("Major");

const parseContractReturnValue = (returnObject, len) => {
  for(let i = 0; i < len; i++) {
    delete returnObject[i];
  }
  let objectKeys = Object.keys(returnObject);
  objectKeys.forEach((key) => {
    returnObject[key] = returnObject[key].toString();
  })
  return returnObject;
}

contract("CURRENCY", (accounts) => {
  it("should put 10^22 TFToken in the first account", async() => {
    const currency = await CURRENCY.deployed();
    const balance = await currency.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("NFT", (accounts) => {
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
  it("The feature of character initialization", async() => {
    const major = await MAJOR.deployed();
    let expectedName = "testName";
    let expectedIsinited = true;
    let expectedPlayerStatus = {name:expectedName, level:"1", experience: "0", distributableAbility: "0"};
    let expectedAbility = {str: "10", intllegence: "10", dex: "10", vit: "10", luk: "10"};
    let expectedEquipment = {helmet: "1", chestplate: "2", leggings: "3", boots: "4", weapon: "10"}
    await major.init(expectedName, {from:accounts[0]});
    
    let actualIsinited = await major.isInited.call(accounts[0]);
    let actualPlayerStatus = await major.playerStatusOf.call(accounts[0]);
    actualPlayerStatus = parseContractReturnValue(actualPlayerStatus, Object.keys(expectedPlayerStatus).length);
    let actualAbility = await major.abilityOf.call(accounts[0]);
    actualAbility = parseContractReturnValue(actualAbility, Object.keys(expectedAbility).length);
    let actualEquipment = await major.equipmentOf.call(accounts[0]);
    actualEquipment = parseContractReturnValue(actualEquipment, Object.keys(expectedEquipment).length);

    
    assert.deepEqual(expectedIsinited, actualIsinited, "isInited was not successfully alterd");
    assert.deepEqual(expectedPlayerStatus, actualPlayerStatus, "playerStatus was not successfully alterd");
    assert.deepEqual(expectedAbility, actualAbility, "ability was not successfully alterd");
    assert.deepEqual(expectedEquipment, actualEquipment, "equipment was not successfully alterd");
  })
});