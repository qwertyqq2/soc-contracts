async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0x4d0D6c49F5dEdA179eD5F729bc9b2FBf67fF3Ac0",
            Proof: "0x70d40C430EFCAF7df1a8a6d0716CA3553e8027cf",
            Params: "0x8F74E84EfCCbDF35Be94c4E97C8064d57b5df0bA",
            JumpSnap: "0x4919bC11E699303ee18062EA655aF6ae5E860DF7"
        },
    });

    const group = contract.attach("0x89e74AFDe268714Ff43Fa62f1e1593f011623698");

    const deposit = 3000

    const createTx = await group.CreateRound(deposit);
    await createTx.wait();

    console.log("new round:", await group.GetRound());

    const accounts = await ethers.getSigners();

    for (let i = 0; i < accounts.length; i++) {
        let enter = await group.connect(accounts[i]).Enter({ value: deposit });
        await enter.wait();
        console.log("enter!");
    }

    await group.StartRound();

    console.log("Round started!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});