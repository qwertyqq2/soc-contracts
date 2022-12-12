async function main() {
    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0xFfe678f76a0bFD7f32e84a647Ba7de7ab4531B41",
            Proof: "0x01D8a95F1d14AFA2f21Bdd9137540B79003f4E9A",
            Params: "0x927b0648387f975f5b50Bb41f4C7Cd05D80ad195",
            JumpSnap: "0xe0aAd47155f173591847Af5AD79855195630eBb5"
        },
    });

    const group = contract.attach("0xd08124f0713032601ac661Fc9944988bf4d6c083");


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