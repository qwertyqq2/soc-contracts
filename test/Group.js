const { expect } = require("chai");
const deposit = BigInt("10000")



beforeEach(async function () {
    const mathLib = await ethers.getContractFactory("Math");
    const mlib = await mathLib.deploy();
    await mlib.deployed();

    const proofLib = await ethers.getContractFactory("Proof");
    const plib = await proofLib.deploy();
    await plib.deployed();

    const paramsLib = await ethers.getContractFactory("Params");
    const paramslib = await paramsLib.deploy();
    await paramslib.deployed();


    const jumpLib = await ethers.getContractFactory("JumpSnap");
    const jumplib = await jumpLib.deploy();
    await jumplib.deployed();

    Group = await ethers.getContractFactory("Group", {
        libraries: {
            Math: mlib.address,
            Proof: plib.address,
            Params: paramslib.address,
            JumpSnap: jumplib.address
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

        const paramsLib = await ethers.getContractFactory("Params");
        const paramslib = await paramsLib.deploy();
        await paramslib.deployed();


        const proofLib = await ethers.getContractFactory("Proof");
        const plib = await proofLib.deploy();
        await plib.deployed();

        const accounts = await ethers.getSigners();


        //Data user//

        let balances = []
        let addresses = []
        let params = []


        for (let i = 0; i < accounts.length; i++) {
            balances.push(BigInt(deposit))
            addresses.push(accounts[i].address)
            params.push(
                {
                    owner: accounts[i].address,
                    balance: deposit,
                    nwin: 0,
                    n: 0,
                    spos: 0,
                    sneg: 0,
                }
            )
        }

        async function GetProofParams(CurrentNumber) {
            let H1 = await group.GetInitSnapRound()
            for (let i = 0; i < CurrentNumber; i++) {
                snap = await paramslib.GetSnapParamPlayerOut(
                    params[i].owner,
                    params[i].balance,
                    params[i].nwin,
                    params[i].n,
                    params[i].spos,
                    params[i].sneg
                )
                H1 = await mlib.xor(H1, snap)
            }
            let H2 = await paramslib.GetSnapParamPlayerOut(
                params[CurrentNumber + 1].owner,
                params[CurrentNumber + 1].balance,
                params[CurrentNumber + 1].nwin,
                params[CurrentNumber + 1].n,
                params[CurrentNumber + 1].spos,
                params[CurrentNumber + 1].sneg
            )
            for (let i = CurrentNumber + 2; i < accounts.length; i++) {
                snap = await paramslib.GetSnapParamPlayerOut(
                    params[i].owner,
                    params[i].balance,
                    params[i].nwin,
                    params[i].n,
                    params[i].spos,
                    params[i].sneg
                )
                H2 = await mlib.xor(H2, snap)
            }
            return await mlib.xor(H1, H2);
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
            return await mlib.xor(H1, H2);
        }

        async function GetProofPlayerDouble(prevnumber, curnumber) {
            let H = await group.GetInitSnapRound();
            for (let i = 0; i < accounts.length; i++) {
                if (i != prevnumber && i != curnumber) {
                    snap = await mlib.GetSnap(addresses[i], balances[i]);
                    H = await mlib.xor(H, snap);
                }
            }
            return H;
        }


        async function IterLot(lotAddr, creatorNumber, ownerNumber, timeF, timeS, value, initPrice) {
            let H;
            H = await GetProofPlayer(creatorNumber);
            await group.connect(accounts[creatorNumber]).NewLot(lotAddr, timeF, timeS,
                initPrice, value, H, balances[creatorNumber]);
            balances[creatorNumber] -= BigInt(Number(initPrice));

            let snapshot = await mlib.GetNewBuySnapshot(accounts[creatorNumber].address, initPrice, 0);


            let owner = accounts[creatorNumber].address;
            let balance = balances[creatorNumber];
            let price = initPrice;
            let prevOwner = owner;
            let prevBalance = balance;
            let prevPrice = price;
            let prevSnapshot = 0;
            let prevNumber = creatorNumber;


            Hp = await GetProofParams(ownerNumber);

            let dataParams = await paramslib.EncodePlayerParams(
                params[ownerNumber].owner,
                params[ownerNumber].balance,
                params[ownerNumber].nwin,
                params[ownerNumber].n,
                params[ownerNumber].spos,
                params[ownerNumber].sneg,
                Hp
            );

            let flag = await group.VerifyParamsPlayer(dataParams);
            console.log(flag);


            for (let i = 1; i <= ownerNumber; i++) {
                Hres = await GetProofPlayer(i);
                Hd = await GetProofPlayerDouble(prevNumber, i);

                price = initPrice + i;
                owner = addresses[i];
                balance = balances[i];


                await group.connect(accounts[i]).BuyLot
                    (lotAddr, price, Hres, Hd, balance,
                        prevBalance, prevOwner, prevPrice, prevSnapshot);

                balances[i] -= BigInt(price);
                balances[prevNumber] += BigInt(price);
                prevBalance = balances[i];
                prevPrice = price;
                prevOwner = owner;
                prevNumber = i;
                prevSnapshot = snapshot;
                snapshot = await mlib.GetNewBuySnapshot(owner, price, snapshot);
            }

            ///Encode send///

            let dataInit = await paramslib.EncodeInitParams(timeF, timeS, value);

            await group.connect(accounts[0]).SendLot(lotAddr, dataInit);

            Hres = await GetProofPlayer(ownerNumber);
            Hp = await GetProofParams(ownerNumber);


            const dataProof = await plib.EncodeProofRes(price, Hres, prevSnapshot);


            Hp = await GetProofParams(ownerNumber);

            dataParams = await paramslib.EncodePlayerParams(
                params[ownerNumber].owner,
                params[ownerNumber].balance,
                params[ownerNumber].nwin,
                params[ownerNumber].n,
                params[ownerNumber].spos,
                params[ownerNumber].sneg,
                Hp
            );

            flag = await group.VerifyParamsPlayer(dataParams);
            console.log(flag);


            const receiveTx = await group.connect(accounts[0]).ReceiveLot(
                lotAddr,
                addresses[ownerNumber],
                balances[ownerNumber],
                dataInit,
                dataProof,
                dataParams
            );

            const result = await receiveTx.wait();

            const newBalance = BigInt(Number(result.events[0].args._newBalance));
            balances[ownerNumber] = newBalance;
        }

        let CreateLotTx = await group.CreateLot();
        let lotTx = await CreateLotTx.wait();
        const lotAddr1 = lotTx.events[0].args._lotAddr;


        let timeF = Date.now() + 120;
        let timeS = timeF + 100;
        let value = 65;
        let initPrice = 100;


        let creatorNumber = 17;
        let ownerNumber = 12;

        await IterLot(lotAddr1, creatorNumber, ownerNumber, timeF, timeS, value, initPrice);
    })
})
