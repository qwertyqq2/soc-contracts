async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0xDAc45A4Af8D0c1D74f564E3E7a7299cEf4C7aa72",
            Proof: "0xb1a7813f3f25e9B28CBA7E858F2ADe1970a9c213",
            Params: "0xAf3342e09C46aB28a9341874e2D2BdbbFd96E07d",
            JumpSnap: "0x5C7A252f9f1c6DC6292183bB0374b365F9361C0B"
        },
    });

    const group = contract.attach("0xaF80CE674D9f1EA125A1c26d31111cA7e05e2a1a");

    console.log("balance: ", await group.GetDepositRound());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});