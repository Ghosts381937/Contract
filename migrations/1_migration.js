const CURRENCY = artifacts.require("Currency");
const RUBY = artifacts.require("Ruby");
const SAPPHIRE = artifacts.require("Sapphire");
const EMERALD = artifacts.require("Emerald");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");
const MAJOR = artifacts.require("Major");

const DEV_ACCOUNTS = ['0x23FdC87bEeC6da70cFD285eD947550fcA69a6e38', '0xbdAba61A2EefC077e4c79425fd9395A371B8D141'];
const TOTAL_SUPPLY = new web3.utils.BN('10000000000000000000000000')
const AMOUNT_TO_MAJOR = TOTAL_SUPPLY.div(new web3.utils.BN('10')) //0.1 * TOTAL_SUPPLY
const AMOUNT_TO_DEV = AMOUNT_TO_MAJOR.mul(new web3.utils.BN('4')) //0.3 * TOTAL_SUPPLY
// const RUBY_ADDRESS = RUBY.address;
// const SAPPHIRE_ADDRESS = SAPPHIRE.address;
// const EMERALD_ADDRESS = EMERALD.address;
const RUBY_ADDRESS = "0x9f713F4d8cEd773Cc9C21cA7260FfeDcb6700360";
const SAPPHIRE_ADDRESS = "0x9B65e0f7B2a138cbF6389c806FB47Cb75474dFc1";
const EMERALD_ADDRESS = "0x6CE464896C385CC5D31EE6c81220E95d5087f3c6";
let drops = [{
    exp: 10, 
    typesOfMaterial: [RUBY_ADDRESS], 
    basesOfMaterial: [web3.utils.toWei('10', 'ether')]
  },{
    exp: 20, 
    typesOfMaterial: [RUBY_ADDRESS, SAPPHIRE_ADDRESS], 
    basesOfMaterial: [web3.utils.toWei('10', 'ether'), web3.utils.toWei('10', 'ether')]
  },{
    exp: 40, 
    typesOfMaterial: [RUBY_ADDRESS, SAPPHIRE_ADDRESS, EMERALD_ADDRESS], 
    basesOfMaterial: [web3.utils.toWei('10', 'ether'), web3.utils.toWei('10', 'ether'), web3.utils.toWei('10', 'ether')]
  },{
    exp: 60, 
    typesOfMaterial: [RUBY_ADDRESS, SAPPHIRE_ADDRESS, EMERALD_ADDRESS], 
    basesOfMaterial: [web3.utils.toWei('20', 'ether'), web3.utils.toWei('20', 'ether'), web3.utils.toWei('20', 'ether')]
  },{
    exp: 100, 
    typesOfMaterial: [RUBY_ADDRESS, SAPPHIRE_ADDRESS, EMERALD_ADDRESS], 
    basesOfMaterial: [web3.utils.toWei('100', 'ether'), web3.utils.toWei('100', 'ether'), web3.utils.toWei('100', 'ether')]
  },
];
let dungeons = [{
    cost: web3.utils.toWei('100', 'ether'), 
    numbersOfOriginEnemy: [200, 0, 0, 0, 0], 
    numbersOfEnemyOnSingleDungeon: [10, 0, 0, 0, 0]
  },{
    cost: web3.utils.toWei('200', 'ether'), 
    numbersOfOriginEnemy: [0, 80, 140, 260, 0], 
    numbersOfEnemyOnSingleDungeon: [0, 4, 7, 13, 0]
  },{
    cost: web3.utils.toWei('1000', 'ether'), 
    numbersOfOriginEnemy: [0, 60, 60, 60, 20], 
    numbersOfEnemyOnSingleDungeon: [0, 3, 3, 3, 1]
  },
];
module.exports = async function(deployer, nil, accounts) {
  // deployment steps
  // await deployer.deploy(RUBY)
  // await deployer.deploy(SAPPHIRE)
  // await deployer.deploy(EMERALD)
  // await deployer.deploy(NFT)
  // await deployer.deploy(CURRENCY)
  // await deployer.deploy(MARKET, CURRENCY.address, NFT.address)
  // await deployer.deploy(MAJOR, CURRENCY.address, NFT.address, RUBY.address, SAPPHIRE.address, EMERALD.address, "0x033b54D48a7d94071fEdf36604C9F82B6c847640")
  
  // const nft = await NFT.deployed();
  // const currency = await CURRENCY.deployed();
  // const ruby = await RUBY.deployed();
  // const sapphire = await SAPPHIRE.deployed();
  // const emerald = await EMERALD.deployed();
  // const major = await MAJOR.deployed();

  // await nft.setSpecificContract(MAJOR.address, {from:accounts[0]})
  // await currency.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  // await ruby.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  // await sapphire.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  // await emerald.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  
  // //for deploy
  // DEV_ACCOUNTS.forEach(async (devAccount) => {
  //   currency.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
  //   ruby.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
  //   sapphire.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
  //   emerald.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
  // })
  
  const major = await MAJOR.at("0xDF2a197aaC6c72A7FcF4fE37b62EB97F6438e9FA")

  for(let index = 0; index < dungeons.length; index++) {
    let dungeon = dungeons[index];
    await major.createDungeon(dungeon.cost, dungeon.numbersOfOriginEnemy, dungeon.numbersOfEnemyOnSingleDungeon, {from:accounts[0]});
  }

  for(let index = 0; index < drops.length; index++) {
    let drop = drops[index];
    await major.createDropsInfo(drop.exp, drop.typesOfMaterial, drop.basesOfMaterial, {from:accounts[0]});
  }

  // while(true) {
  //   let sapphireBalance = await sapphire.balanceOf.call(DEV_ACCOUNTS[1]);
  //   let emeraldBalance = await emerald.balanceOf.call(DEV_ACCOUNTS[1]);
  //   if(emeraldBalance.toString() !== '0' && sapphireBalance.toString() !== '0') {
  //     break;
  //   }
  // }
}