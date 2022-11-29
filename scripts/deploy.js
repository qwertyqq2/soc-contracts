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

  const accounts = await ethers.getSigners();

  const deposit = 3000

  let createRound = await group.CreateRound(deposit);
  await createRound.wait();
  console.log("round created");

  for (let i = 0; i < accounts.length; i++) {
    let enter = await group.connect(accounts[i]).Enter({ value: deposit });
    await enter.wait();
    console.log("enter");
  }

  let startRound = await group.StartRound();
  await startRound.wait();
  console.log("round started");
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});