async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0xa7040CcC6d1A95ff80bf159E560Fcfda58a9cD44",
            Proof: "0x7304ad33066DD731693a3C92cd8f84fA3f713CeF",
            Params: "0x3ef6183ffc8081157aa00cb201ABe354283De9EE",
            JumpSnap: "0x6A047261eAE04981464d0070c28020343FF1C152"
        },
    });

    const group = contract.attach("0xD1A6edbe1fa1ed7E87374Fe464C2eD3e0a5DbcA3");


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
    //lotTx.events[4].args._lotAddr
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});