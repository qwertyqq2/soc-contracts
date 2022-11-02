const { expect } = require("chai");
const { utils } = require("ethers");
const web3 = require('web3');
const deposit = BigInt("10000")

beforeEach(async function () {
    Group = await ethers.getContractFactory("Group")
    group = await Group.deploy()
    await group.CreateRound(deposit)
    const accounts = await ethers.getSigners();
    for (let i = 0; i < accounts.length; i++) {
        await group.connect(accounts[i]).Enter({ value: deposit })
    }
    await group.StartRound()


})


describe("Verify", async () => {
    it("Part", async () => {
        const accounts = await ethers.getSigners();
        let owners = []
        let prices = []

        const timeF = 123123123
        const timeS = 1231231231212
        const price = 100
        const value = 10

        await group.CreateLot(timeF, timeS, price, value)
        //owners.push(accounts[0].address)
        //prices.push(100)
        let snap = web3.utils.soliditySha3(
            { type: "uint256", value: timeF },
            { type: "uint256", value: timeS },
            { type: "address", value: accounts[0].address },
            { type: "uint256", value: price },
            { type: "uint256", value: value }

        )
        //timeFirst, timeSecond, owner, price, value
        let i = 1
        const countIter = 6
        for (i = 1; i < countIter / 2; i++) {
            for (let j = 1; j < accounts.length; j++) {
                await group.connect(accounts[j]).BuyLot(100 + i * 10 + j)
                snap = web3.utils.soliditySha3(
                    { type: "address", value: accounts[j].address },
                    { type: "uint256", value: 100 + i * 10 + j },
                    { type: "uint256", value: snap }
                )
            }
        }

        for (i1 = i + 1; i1 < countIter; i1++) {
            for (let j = 1; j < accounts.length; j++) {
                owners.push(accounts[j].address)
                prices.push(100 + i1 * 10 + j)
                await group.connect(accounts[j]).BuyLot(100 + i1 * 10 + j)
            }
        }

        group.TryVerifyPart(owners, prices, snap)

    })

    it("Full", async () => {
        const accounts = await ethers.getSigners();
        let owners = []
        let prices = []

        const timeF = 123123123
        const timeS = 1231231231212
        const price = 100
        const value = 10

        await group.CreateLot(timeF, timeS, price, value)
        owners.push(accounts[0].address)
        prices.push(100)
        let snap = web3.utils.soliditySha3(
            { type: "uint256", value: timeF },
            { type: "uint256", value: timeS },
            { type: "address", value: accounts[0].address },
            { type: "uint256", value: price },
            { type: "uint256", value: value }

        )
        //address[] memory _owners, uint256[] memory _prices, uint256 _timeFirst, 
        //uint256 _timeSecond, uint256 _value
        const countIter = 6
        for (let i = 1; i < countIter; i++) {
            for (let j = 1; j < accounts.length; j++) {
                await group.connect(accounts[j]).BuyLot(100 + i * 10 + j)
                owners.push(accounts[j].address)
                prices.push(100 + i * 10 + j)
                snap = web3.utils.soliditySha3(
                    { type: "address", value: accounts[j].address },
                    { type: "uint256", value: 100 + i * 10 + j },
                    { type: "uint256", value: snap }
                )
            }
        }

        group.TryVerifyFull(owners, prices, timeF, timeS, value)

    })
})


async function Additives(accounts, snap) {
    for (let k = 0; k < 10; k++) {
        await group.connect(accounts[k]).JoinLot(10 + k)
        snap = web3.utils.soliditySha3(
            { type: "address", value: accounts[k].address },
            { type: "uint256", value: 10 + k },
            { type: "uint256", value: snap })
    }
    return snap
}

async function AdditivesParams(accounts, support, additives, sizes) {
    for (let k = 0; k < 10; k++) {
        await group.connect(accounts[k]).JoinLot(10 + k)
        support.push(accounts[k].address)
        additives.push(10 + k)
    }
    sizes.push(10)
}

describe.only("Mistake", async () => {
    it("Substitution", async () => {
        const accounts = await ethers.getSigners();
        let owners = []
        let prices = []
        let support = []
        let additives = []
        let sizes = []

        //Lot//

        const timeF = 123123123
        const timeS = 1231231231212
        const price = 100
        const value = 10

        await group.CreateLot(timeF, timeS, price, value)
        let snap = web3.utils.soliditySha3(
            { type: "uint256", value: timeF },
            { type: "uint256", value: timeS },
            { type: "address", value: accounts[0].address },
            { type: "uint256", value: price },
            { type: "uint256", value: value }

        )
        snap = await Additives(accounts, snap)



        let i = 1
        let j = 1
        const countIter = 6
        for (i = 1; i < countIter / 2; i++) {
            for (j = 1; j < accounts.length; j++) {
                await group.connect(accounts[j]).BuyLot(100 + i * 10 + j)
                snap = web3.utils.soliditySha3(
                    { type: "address", value: accounts[j].address },
                    { type: "uint256", value: 100 + i * 10 + j },
                    { type: "uint256", value: snap }
                )
                snap = await Additives(accounts, snap)
            }

        }
        //Mistake//



        await group.connect(accounts[2]).BuyLot(160)
        owners.push(accounts[2].address)
        prices.push(160)
        await AdditivesParams(accounts, support, additives, sizes)

        await group.connect(accounts[3]).BuyLot(40)
        owners.push(accounts[3].address)
        prices.push(40)
        await AdditivesParams(accounts, support, additives, sizes)



        for (i1 = i + 1; i1 < countIter; i1++) {
            for (let j = 1; j < accounts.length; j++) {
                owners.push(accounts[j].address)
                prices.push(110 + i1 * 10 + j)
                await group.connect(accounts[j]).BuyLot(110 + i1 * 10 + j)

                await AdditivesParams(accounts, support, additives, sizes)
            }
        }
        group.Correct(owners, prices, support, additives, sizes, snap)
    })
})

describe("Trade", async () => {
    it("Join", async () => {
        const accounts = await ethers.getSigners();


        //Lot//

        const timeF = 123123123
        const timeS = 1231231231212
        const price = 100
        const value = 10

        await group.CreateLot(timeF, timeS, price, value)
        let snap = web3.utils.soliditySha3(
            { type: "uint256", value: timeF },
            { type: "uint256", value: timeS },
            { type: "address", value: accounts[0].address },
            { type: "uint256", value: price },
            { type: "uint256", value: value }

        )
        console.log(snap)
        let snapshot = await group.GetSnap()
        console.log(web3.utils.toHex(snapshot))

        await group.connect(accounts[1]).BuyLot(101)
        snap = web3.utils.soliditySha3(
            { type: "address", value: accounts[1].address },
            { type: "uint256", value: 101 },
            { type: "uint256", value: snap }
        )
        snap = await Additives(accounts, snap)
        snapshot = await group.GetSnap()
    })
})

