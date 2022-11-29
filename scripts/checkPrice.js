async function main() {

    const Router = await ethers.getContractFactory("contracts/UniswapRouter/UniswapRouter.sol:UniV3Router");

    const router = Router.attach("0xCC11d34B7c31E6953703bA99c84dde04554e948D");

    let price1 = await router.callStatic.curPriceWETHtoDAI(100000000);
    let price2 = await router.callStatic.curPriceDAItoWETH(100000);


    console.log(price1, price2);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});


//BigNumber { value: "3884518" } BigNumber { value: "2558898" }