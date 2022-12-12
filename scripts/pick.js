async function main() {

    const maddr = "0x4BF09a16Fe8116E868be2A6F66214c945b8cc2ad"
    const paddr = "0xD4c419d7f993B0bFbB12A82998D83a1114BAeDD9"
    const paramaddr = "0xA1AFf5C6cDd727bDa6581e125Bfcf8F4E952bc91"
    const jumpaddr = "0x07d64e2f0650573bD9F6DF1E8B76b74826fBF946"
    const groupaddr = "0xd814e020D39BE49bF8A56362c90A4c320D991A62"
    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: maddr,
            Proof: paddr,
            Params: paramaddr,
            JumpSnap: jumpaddr
        },
    });
    const group = contract.attach(groupaddr);

    data = await group.GetLionDota()
    console.log(data)
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});