const { expect } = require("chai");
const deposit = BigInt("10000")
const Web3 = require('web3');
const web3 = new Web3;


describe.only("Snapshot players", async () => {
    it.only("send successfully", async () => {
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


        const Group = await ethers.getContractFactory("Group", {
            libraries: {
                Math: mlib.address,
                Proof: plib.address,
                Params: paramslib.address,
                JumpSnap: jumplib.address
            },
        });

        group = await Group.deploy();
        console.log(group.address);



        const createRoundTx = await group.CreateRound(1000);
        const createRound = await createRoundTx.wait()

        const deposit = createRound.events[0].args._deposit;
        const roundAddr = createRound.events[0].args._roundAddress;


        console.log("round created", roundAddr)

        const accounts = await ethers.getSigners();

        const pendingPlayers = []

        for (let i = 0; i < accounts.length; i++) {
            const pending = await (await group.connect(accounts[i]).Enter({ value: deposit })).wait()
            pendingPlayers.push({
                sender: pending.events[0].args._sender
            })
        }

        await (await group.StartRound()).wait()


        let balances = []
        let params = []


        for (let i = 0; i < accounts.length; i++) {
            balances.push(BigInt(deposit))
            params.push(
                {
                    owner: accounts[i].address,
                    nwin: 0,
                    n: 0,
                    spos: 0,
                    sneg: 0,
                }
            )
        }

        async function GetProofParams(CurrentNumber) {
            let H = ethers.BigNumber.from("115792089237316195423570985008687907853269984665640564039457584007913129639935");
            let snap;
            for (let i = 0; i < accounts.length; i++) {
                if (i != CurrentNumber) {
                    snap = await paramslib.GetSnapParamPlayerOut(
                        params[i].owner,
                        params[i].nwin,
                        params[i].n,
                        params[i].spos,
                        params[i].sneg
                    )
                    H = await mlib.xor(H, snap)
                }
            }
            return H;
        }

        async function GetProofPlayer(CurrentNumber) {
            let H = ethers.BigNumber.from("115792089237316195423570985008687907853269984665640564039457584007913129639935");
            for (let i = 0; i < accounts.length; i++) {
                if (i != CurrentNumber) {
                    const snap = await mlib.GetSnap(accounts[i].address, balances[i]);
                    H = await mlib.xor(H, snap);
                }
            }
            return H;
        }

        async function GetProofPlayerDouble(prevnumber, curnumber) {
            let H = ethers.BigNumber.from("115792089237316195423570985008687907853269984665640564039457584007913129639935");
            for (let i = 0; i < accounts.length; i++) {
                if (i != prevnumber && i != curnumber) {
                    const snap = await mlib.GetSnap(accounts[i].address, balances[i]);
                    H = await mlib.xor(H, snap);
                }
            }
            return H;
        }

        async function IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice) {
            const lotTx = await (await group.CreateLot()).wait();
            const lotAddr = lotTx.events[0].args._lotAddr;
            console.log("lot created", lotAddr);
            let Hres = await GetProofPlayer(creatorNumber);

            let dataProofRes = web3.eth.abi.encodeParameters(
                ['uint256', 'uint256', 'uint256'],
                [balances[creatorNumber], initPrice, Hres]
            );

            let dataInit = web3.eth.abi.encodeParameters(
                ['uint256', 'uint256', 'uint256'],
                [timeF, timeS, value]
            );

            await (await group.connect(accounts[creatorNumber]).NewLot(lotAddr, dataInit, dataProofRes)).wait();

            balances[creatorNumber] -= BigInt(initPrice);

            let snapshot = await mlib.GetNewBuySnapshot(accounts[creatorNumber].address, initPrice, 0);

            let owner = accounts[creatorNumber].address;
            let balance = balances[creatorNumber];
            let price = initPrice;
            let prevOwner = owner;
            let prevBalance = balance;
            let prevPrice = price;
            let prevSnapshot = 0;
            let prevNumber = creatorNumber;


            for (let i = 1; i <= ownerNumber; i++) {
                Hres = await GetProofPlayer(i);
                Hd = await GetProofPlayerDouble(prevNumber, i);

                price = initPrice + i;
                owner = accounts[i].address;
                balance = balances[i];

                // uint _balance,
                // uint256 _price,
                // uint _Hres,
                // uint _Hd,
                // uint _prevSnap,
                // address _prevOwner,
                // uint _prevBalance
                let dataProofRes = web3.eth.abi.encodeParameters(
                    ['uint256', 'uint256', 'uint256', 'uint256', 'address', 'uint256'],
                    [balance, price, Hres, Hd, prevOwner, prevBalance]
                );

                let dataProofEP = web3.eth.abi.encodeParameters(
                    ['address', 'uint256', 'uint256'],
                    [prevOwner, prevPrice, prevSnapshot]
                );

                await (await group.connect(accounts[i]).BuyLot(lotAddr, dataProofRes, dataProofEP)).wait();

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

            await group.connect(accounts[0]).SendLot(lotAddr, dataInit);

            Hres = await GetProofPlayer(ownerNumber);
            Hp = await GetProofParams(ownerNumber);


            dataProofRes = web3.eth.abi.encodeParameters(
                ['uint256', 'uint256', 'uint256', 'uint256'],
                [balances[ownerNumber], price, Hres, prevSnapshot]
            );


            Hp = await GetProofParams(ownerNumber);

            dataParams = web3.eth.abi.encodeParameters(
                ['address', 'uint', 'uint', 'uint', 'uint', 'uint'],
                [params[ownerNumber].owner,
                params[ownerNumber].nwin,
                params[ownerNumber].n,
                params[ownerNumber].spos,
                params[ownerNumber].sneg,
                    Hp]
            );



            const receiveTx = await group.connect(accounts[0]).ReceiveLot(
                lotAddr,
                accounts[ownerNumber].address,
                dataInit,
                dataProofRes,
                dataParams
            );

            const result = await receiveTx.wait();

            const newBalance = BigInt(Number(result.events[1].args._balance));
            const newParam = result.events[0].args;
            balances[ownerNumber] = newBalance;
            params[ownerNumber].nwin = newParam._nwin;
            params[ownerNumber].n = newParam._n;
            params[ownerNumber].spos = newParam._spos;
            params[ownerNumber].sneg = newParam._sneg;
        }

        let CreateLotTx = await group.CreateLot();
        let lotTx = await CreateLotTx.wait();
        const lotAddr1 = lotTx.events[0].args._lotAddr;


        let timeF = Date.now() + 120;
        let timeS = timeF + 100;
        let value = 65;
        let initPrice = 100;


        let creatorNumber = 14;
        let ownerNumber = 12;

        await IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice);

        timeF = Date.now() + 120;
        timeS = timeF + 100;
        value = 200;
        initPrice = 300;


        creatorNumber = 9;
        ownerNumber = 7;

        await IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice);

        timeF = Date.now() + 120;
        timeS = timeF + 100;
        value = 200;
        initPrice = 300;


        creatorNumber = 15;
        ownerNumber = 10;

        await IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice);

        timeF = Date.now() + 120;
        timeS = timeF + 100;
        value = 200;
        initPrice = 300;


        creatorNumber = 13;
        ownerNumber = 14;

        await IterLot(creatorNumber, ownerNumber, timeF, timeS, value, initPrice);

        console.log(balances)
    })
})