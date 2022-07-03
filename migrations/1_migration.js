var TFToken = artifacts.require("TFToken");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(TFToken, "1000");
};