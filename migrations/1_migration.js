const CURRENCY = artifacts.require("Currency");
const RUBY = artifacts.require("Ruby");
const SAPPHIRE = artifacts.require("Sapphire");
const EMERALD = artifacts.require("Emerald");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");
const MAJOR = artifacts.require("Major");

module.exports = async function(deployer, nil, accounts) {
  // deployment steps
  await deployer.deploy(CURRENCY)
  await deployer.deploy(RUBY)
  await deployer.deploy(SAPPHIRE)
  await deployer.deploy(EMERALD)
  await deployer.deploy(NFT)
  await deployer.deploy(MARKET, CURRENCY.address, NFT.address)
  await deployer.deploy(MAJOR, CURRENCY.address, NFT.address, RUBY.address, SAPPHIRE.address, EMERALD.address)


  const nft = await NFT.deployed();
  await nft.setSpecificContract(MARKET.address, {from:accounts[0]})


  

  
}