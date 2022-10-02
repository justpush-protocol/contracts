var JustPushV1 = artifacts.require("./JustPushV1.sol");

module.exports = function(deployer) {
  deployer.deploy(JustPushV1, process.env.GOVERNANCE);
  console.log("JustPushV1 deployed to network");
};
