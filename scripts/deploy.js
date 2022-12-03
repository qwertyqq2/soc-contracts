async function main() {

  const mathLib = await ethers.getContractFactory("Math");
  const mlib = await mathLib.deploy();
  await mlib.deployed();
  console.log("Math address: ", mlib.address);


  const proofLib = await ethers.getContractFactory("Proof");
  const plib = await proofLib.deploy();
  await plib.deployed();
  console.log("Proof address: ", plib.address);

  const paramsLib = await ethers.getContractFactory("Params");
  const paramslib = await paramsLib.deploy();
  await paramslib.deployed();
  console.log("Params address: ", paramslib.address);

  const jumpLib = await ethers.getContractFactory("JumpSnap");
  const jumplib = await jumpLib.deploy();
  await jumplib.deployed();
  console.log("JumpSnap address: ", jumplib.address)


  Group = await ethers.getContractFactory("Group", {
    libraries: {
      Math: mlib.address,
      Proof: plib.address,
      Params: paramslib.address,
      JumpSnap: jumplib.address
    },
  });

  group = await Group.deploy()

  console.log("Group created, address:", group.address);


}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});