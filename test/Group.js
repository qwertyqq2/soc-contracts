const { expect } = require("chai");

const deposit = BigInt("10000")


beforeEach(async function () {
    Group = await ethers.getContractFactory("Group")
    group = await Group.deploy()
    await group.CreateRound(deposit)
})


describe("Trade", async () => {
    it("Start", async () => {
        const accounts = await ethers.getSigners();
        for (let i = 0; i < accounts.length; i++) {
            await group.connect(accounts[i]).Enter({ value: deposit })
        }
        await group.StartRound()

        let timeF = BigInt(123123123)
        let timeS = BigInt(1231231231212)
        let price = 100
        let value = 10
        await group.CreateLot(timeF, timeS, price, value)

        await group.connect(accounts[1]).BuyLot(120)

    })
})