const hre = require("hardhat");
async function main() {
  const Group = await hre.ethers.getContractFactory("Group");
  const group = await Group.deploy();
  await group.deployed();



  console.log("Group created")
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});