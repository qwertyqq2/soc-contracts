async function main() {
    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0xEA5efF5c7BF7C307255E91013092220F7585e8be",
            Proof: "0xD494E1F2Fe0f59F0df821a3c22c519e8Fd5a3F8A",
            Params: "0x2D86f65f8Ff7809998BB3ed99387E56cc3a3dB74",
            JumpSnap: "0x8dEAB96676322c60b1f1EF2A46535F788422f7E0"
        },
    });

    const group = contract.attach("0x70b8E5De6224Bd4A5De5089e5bB0F4D8Cf1e771d");


    const accounts = await ethers.getSigners();

    const deposit = 1000

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

    let lotTx = await (await group.CreateLot()).wait();
    let lotAddr = lotTx.events[0].args._lotAddr;
    console.log("lot created", lotAddr);

    lotTx = await (await group.CreateLot()).wait();
    lotAddr = lotTx.events[0].args._lotAddr;
    console.log("lot created", lotAddr);

    lotTx = await (await group.CreateLot()).wait();
    lotAddr = lotTx.events[0].args._lotAddr;
    console.log("lot created", lotAddr);
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});