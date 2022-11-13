const { expect } = require("chai");
const deposit = BigInt("10000")



beforeEach(async function () {
    const mathLib = await ethers.getContractFactory("Math");
    const mlib = await mathLib.deploy();
    await mlib.deployed();

    const proofLib = await ethers.getContractFactory("Proof");
    const plib = await proofLib.deploy();
    await plib.deployed();

    const prizeLib = await ethers.getContractFactory("Prize");
    const prizelib = await prizeLib.deploy();
    await prizelib.deployed();

    Group = await ethers.getContractFactory("Group", {
        libraries: {
            Math: mlib.address,
            Proof: plib.address,
            Prize: prizelib.address,
        },
    });

    group = await Group.deploy()
    await group.CreateRound(deposit)
    const accounts = await ethers.getSigners();

    for (let i = 0; i < accounts.length; i++) {
        await group.connect(accounts[i]).Enter({ value: deposit })
    }
    await group.StartRound()
})





describe.only("Snapshot players", async () => {
    it("Init", async () => {
        const mathLib = await ethers.getContractFactory("Math");
        const mlib = await mathLib.deploy();
        await mlib.deployed();

        const accounts = await ethers.getSigners();

        const N = 10;
        const myAddr = accounts[N].address
        let myBalance = deposit
        const hash = await mlib.GetSnap(myAddr, myBalance)


        let H1 = await group.GetInitSnapRound()

        for (let i = 0; i < N; i++) {
            snap = await mlib.GetSnap(accounts[i].address, deposit)
            H1 = await mlib.xor(H1, snap)
        }

        let H2 = await mlib.GetSnap(accounts[N + 1].address, deposit)
        for (let i = N + 2; i < accounts.length; i++) {
            snap = await mlib.GetSnap(accounts[i].address, deposit)
            H2 = await mlib.xor(H2, snap)
        }

        const part = await mlib.xor(H1, hash)
        const res = await mlib.xor(part, H2)
        const myValue = await mlib.KeccakOne(res)
        const snapshot = await group.GetSnapRound()

        expect(myValue).to.equal(snapshot)

    })

    it.only("send successfully", async () => {
        const mathLib = await ethers.getContractFactory("Math");
        const mlib = await mathLib.deploy();
        await mlib.deployed();

        const accounts = await ethers.getSigners();

        //Data user//

        let balances = []
        let addresses = []

        for (let i = 0; i < accounts.length; i++) {
            balances.push(deposit)
            addresses.push(accounts[i].address)
        }

        async function GetProofPlayer(CurrentNumber) {
            let H1 = await group.GetInitSnapRound()
            for (let i = 0; i < CurrentNumber; i++) {
                snap = await mlib.GetSnap(addresses[i], balances[i])
                H1 = await mlib.xor(H1, snap)
            }
            let H2 = await mlib.GetSnap(accounts[CurrentNumber + 1].address, balances[CurrentNumber + 1])
            for (let i = CurrentNumber + 2; i < accounts.length; i++) {
                snap = await mlib.GetSnap(accounts[i].address, balances[i])
                H2 = await mlib.xor(H2, snap)
            }
            return [H1, H2]
        }


        async function IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice) {
            let H1, H2;
            [H1, H2] = await GetProofPlayer(creatorNumber);
            await group.connect(accounts[creatorNumber]).CreateLot(timeF, timeS,
                initPrice, value, H1, H2, balances[creatorNumber]);

            let snapshot = await mlib.GetNewBuySnapshot(accounts[creatorNumber].address, initPrice, 0);

            let prevSnapshot = 0;
            let curowner = accounts[creatorNumber].address;
            let curprice = initPrice;

            for (let i = 1; i <= ownerNumber; i++) {
                [H1, H2] = await GetProofPlayer(i);
                await group.connect(accounts[i]).BuyLot(initPrice + i, H1, H2, balances[i],
                    curowner, curprice, prevSnapshot);
                prevSnapshot = snapshot;
                curowner = accounts[i].address;
                curprice = initPrice + i;
                snapshot = mlib.GetNewBuySnapshot(accounts[i].address, initPrice + i, snapshot);
            }

            await group.connect(accounts[0]).SendLot(timeF, timeS, value);

            [H1, H2] = await GetProofPlayer(ownerNumber);


            const receiveTx = await group.connect(accounts[0]).ReceiveLot(timeF, timeS, value,
                curowner, curprice, H1, H2, balances[ownerNumber], prevSnapshot);

            const result = await receiveTx.wait();

            const newBalance = BigInt(Number(result.events[0].args._newBalance));
            balances[ownerNumber] = newBalance;
        }

        async function Iter(CountIter) {
            for (let i = 0; i < CountIter; i++) {
                let timeF = Date.now() + 120;
                let timeS = timeF + 100;
                let value = 65;
                let initPrice = 100;


                let creatorNumber = i % 15 + 2;
                let ownerNumber = i % 15 + 3;
                await IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice)
            }
        }

        await Iter(20);

        console.log(balances)

    })

    it("Cancel", async () => {
        const mathLib = await ethers.getContractFactory("Math");
        const mlib = await mathLib.deploy();
        await mlib.deployed();

        const accounts = await ethers.getSigners();

        //Data user//

        let balances = []
        let addresses = []

        for (let i = 0; i < accounts.length; i++) {
            balances.push(deposit)
            addresses.push(accounts[i].address)
        }

        async function GetProofPlayer(N) {
            let H1 = await group.GetInitSnapRound()
            for (let i = 0; i < N; i++) {
                snap = await mlib.GetSnap(addresses[i], balances[i])
                H1 = await mlib.xor(H1, snap)
            }
            let H2 = await mlib.GetSnap(accounts[N + 1].address, deposit)
            for (let i = N + 2; i < accounts.length; i++) {
                snap = await mlib.GetSnap(accounts[i].address, deposit)
                H2 = await mlib.xor(H2, snap)
            }
            return [H1, H2]
        }


        const N = 10;
        [H1, H2] = await GetProofPlayer(N)


        //lot//`
        const timeF = 123123123
        const timeS = 1231231231212
        const price = 100
        const value = 10

        await group.connect(accounts[N]).CreateLot(timeF, timeS, price, value, H1, H2, balances[N]);
        let snapshot = await mlib.GetNewBuySnapshot(accounts[N].address, price, 0);
        [H1, H2] = await GetProofPlayer(N);
        let prevSnapshot = 0
        let prevOwner = accounts[N].address
        let prevPrice = price
        const last = 10
        for (let i = 1; i <= last; i++) {
            [H1, H2] = await GetProofPlayer(i)
            await group.connect(accounts[i]).BuyLot(price + i, H1, H2, balances[i],
                prevOwner, prevPrice, prevSnapshot)
            prevSnapshot = snapshot
            prevOwner = accounts[i].address
            prevPrice = price + i
            snapshot = mlib.GetNewBuySnapshot(accounts[i].address, price + i, snapshot)
        }

        [H1, H2] = await GetProofPlayer(0);
        await group.connect(accounts[0]).CancelLot(price + last, H1, H2, balances[0],
            prevOwner, prevPrice, prevSnapshot)


        await group.SendCancelLot(timeF, timeS, value, accounts[0].address)
        await group.ReceiveCancelLot(timeF, timeS, value, accounts[0].address)
    })

})
