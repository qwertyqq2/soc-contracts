async function main() {
    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0x0aFB7096fB5BED307543284a70d323a742887806",
            Proof: "0x26a686F6223612c3C570CC557690ad91B6ea25a1",
            Params: "0x90cd6779D9168a572dB9686A77608CD3b94F5204",
            JumpSnap: "0xac71A758894A6191E72aA3f2C2810368282A8375"
        },
    });

    const group = contract.attach("0x73f914E7E05f2cA4F2fBe92b0CDD437094773943");



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