const CURRENCY = artifacts.require("Currency");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");

module.exports = async function(deployer, nil, accounts) {
  // deployment steps
  await deployer.deploy(CURRENCY)
  await deployer.deploy(NFT)
  await deployer.deploy(MARKET, CURRENCY.address, NFT.address)

  const nft = await NFT.deployed();
  await nft.setSpecificContract(MARKET.address, {from:accounts[0]})
  
}