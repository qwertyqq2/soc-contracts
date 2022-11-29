async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0x97a72E5B576c92271F8dD8C54a99E1b114D6b85E",
            Proof: "0xA5de3AF81B9400375c7631b58922A4737A768Aa1",
            Params: "0x794B32827D690D36EEA7249b5f273A92F34bc6C5",
            JumpSnap: "0x7997d2404C7c27cB1Eb24a886ba9463872E2f1E8"
        },
    });

    const group = contract.attach("0x6c509668E26f1F0e14E6F4E97CbdfF99C9cfA03C");

    const accounts = await ethers.getSigners();


    let startRound = await group.StartRound();
    await startRound.wait();
    console.log("round started");
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});