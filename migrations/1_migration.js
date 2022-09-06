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
module.exports = async function(deployer, nil, accounts) {
  // deployment steps
  await deployer.deploy(RUBY)
  await deployer.deploy(SAPPHIRE)
  await deployer.deploy(EMERALD)
  await deployer.deploy(NFT)
  await deployer.deploy(CURRENCY)
  await deployer.deploy(MARKET, CURRENCY.address, NFT.address)
  await deployer.deploy(MAJOR, CURRENCY.address, NFT.address, RUBY.address, SAPPHIRE.address, EMERALD.address)
  
  const nft = await NFT.deployed();
  const currency = await CURRENCY.deployed();
  const ruby = await RUBY.deployed();
  const sapphire = await SAPPHIRE.deployed();
  const emerald = await EMERALD.deployed();

  nft.setSpecificContract(MAJOR.address, {from:accounts[0]})
  currency.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  ruby.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  sapphire.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  emerald.transfer(MAJOR.address, AMOUNT_TO_MAJOR, {from:accounts[0]})
  
  DEV_ACCOUNTS.forEach(async (devAccount) => {
    currency.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
    ruby.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
    sapphire.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
    emerald.transfer(devAccount, AMOUNT_TO_DEV, {from:accounts[0]})
  })

  while(true) {
    let sapphireBalance = await sapphire.balanceOf.call(DEV_ACCOUNTS[1]);
    let emeraldBalance = await emerald.balanceOf.call(DEV_ACCOUNTS[1]);
    if(emeraldBalance.toString() !== '0' && sapphireBalance.toString() !== '0') {
      break;
    }
  }
}