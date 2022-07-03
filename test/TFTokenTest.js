const TFToken = artifacts.require("TFToken");

contract("TFToken", (accounts) => {
  it("should put 10000 TFToken in the first account", async () => {
    const TFTokenInstance = await TFToken.deployed();
    const balance = await TFTokenInstance.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
  });
});