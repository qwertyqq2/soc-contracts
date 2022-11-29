async function main() {
    const Router = await ethers.getContractFactory("contracts/UniswapRouter/UniswapRouter.sol:UniV3Router");

    const router = await Router.deploy()

    console.log("router address: ", router.address);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
