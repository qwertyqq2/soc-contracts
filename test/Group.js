const { expect } = require("chai");

const deposit = BigInt("10000")


beforeEach(async function () {
    Group = await ethers.getContractFactory("Group")
    group = await Group.deploy()
    await group.CreateRound(deposit)
})


describe("Group", async () => {
    it("Create Round", async () => {
        const accounts = await ethers.getSigners();
        for (let i = 0; i < accounts.length; i++) {
            await group.connect(accounts[i]).Enter({ value: deposit })
        }
        await group.connect(accounts[0]).StartRound()
    })

    // it("Create lot", async () => {
    //     const accounts = await ethers.getSigners();
    //     let timeF = BigInt("1231231231231")
    //     let timeS = BigInt("1231231231231121")
    //     let price = BigInt("100")
    //     let val = BigInt("10")
    //     await group.connect(accounts[0]).CreateLot(timeF, timeS, price, val)
    //     let snap = await group.GetSnap()
    //     console.log(snap)
    // })

});