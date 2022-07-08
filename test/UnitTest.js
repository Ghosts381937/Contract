const CURRENCY = artifacts.require("Currency");
const NFT = artifacts.require("Nft");
const MARKET = artifacts.require("Market");

contract("CURRENCY", (accounts) => {
  it("should put 10^22 TFToken in the first account", async () => {
    const currency = await CURRENCY.deployed();
    const balance = await currency.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), web3.utils.toWei('10000', 'ether'), "10000 wasn't in the first account");
  });
});
contract("NFT", (accounts) => {
  it("should be 'Test' in the [name]", async () => {
    const nft = await NFT.deployed();
    const name = await nft.name.call();

    assert.equal(name, 'Test', "'Test' wasn't in the [name]");
  });
  it("should be MARKET.address in the [specificContract]", async () => {
    const nft = await NFT.deployed();
    const address = await nft.specificContract.call();

    assert.equal(address, MARKET.address, "'MARKET.address' wasn't in the [specificContract]");
  });
});