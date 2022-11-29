async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0xc91214774ff8947faC88091DfEDe8d76B5448caE",
            Proof: "0x31aefAA09854b0bAE01a4d9e7b358f83830AFa1A",
            Params: "0x9e5ac51386C4D08caf1A489805d922b26AdbB8Ee",
            JumpSnap: "0xB925345B6d56Ae4Be3F4252cF589Ca91EE523dB9"
        },
    });

    const group = contract.attach("0xe9BeC51b5ad1fa55d475a023063542aD16Cb984F");


    let priceTx = await group.CurrentPrice1(1000);
    let price1 = await priceTx.wait();
    console.log("price1: ", price1.events[0].args._amountOut);

    priceTx = await group.CurrentPrice1(1000);
    let price2 = await priceTx.wait();
    console.log("price2: ", price2.events[0].args._amountOut);


}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
//    const requiredEth1 = await swapper.callStatic.ReadPrice(1000);