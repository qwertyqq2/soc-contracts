async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0x05C04c43752fF0d5726b5Bc1b2F23C7f1861a709",
            Proof: "0x15C967F9BC3bEf0C1C7e522D2f75EecAeBcEb5B1",
            Params: "0x30dFae12b22AeB69D89E5449C83847955ef1Ed9a",
            JumpSnap: "0xaF03022C0ED6b5457599Bb97e83BDe938bA65FbB"
        },
    });

    const group = contract.attach("0x264d28b1E8EC9aE0DBa1888668298939e2b0F04d");

    await group.SwapDaiToEth(269);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});