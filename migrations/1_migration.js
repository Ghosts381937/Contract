const CURRENCY = artifacts.require("Currency");
const RUBY = artifacts.require("Ruby");
const SAPPHIRE = artifacts.require("Sapphire");
const EMERALD = artifacts.require("Emerald");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");
const MAJOR = artifacts.require("Major");

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

  await nft.setSpecificContract(MAJOR.address, {from:accounts[0]})
  await currency.transfer(MAJOR.address, web3.utils.toWei('5000', 'ether'), {from:accounts[0]});
  await ruby.transfer(MAJOR.address, web3.utils.toWei('5000', 'ether'), {from:accounts[0]});
  await sapphire.transfer(MAJOR.address, web3.utils.toWei('5000', 'ether'), {from:accounts[0]});
  await emerald.transfer(MAJOR.address, web3.utils.toWei('5000', 'ether'), {from:accounts[0]})

}