const Web3 = require('web3');
const web3 = new Web3;


async function main() {


    const maddr = "0x3E3030fC5B906D1D8864176fc08FB8ea101A1f22"
    const paddr = "0x61Fc53A3E19164B9261D4268C5E8e41b9DeFC579"
    const paramaddr = "0x33d9E4eE09f006da95F0C849389d3e3AaeC43025"
    const jumpaddr = "0x6222110F2aCaC28e372be95Ba1d3E038534F1917"
    const groupaddr = "0xaE60f7C7701A2D497db5601147B46e415C422275"
    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: maddr,
            Proof: paddr,
            Params: paramaddr,
            JumpSnap: jumpaddr
        },
    });

    const group = contract.attach(groupaddr);
    console.log("attach");

    const mathLib = await ethers.getContractFactory("Math");
    const mlib = mathLib.attach(maddr);

    const pLib = await ethers.getContractFactory("Proof");
    const plib = pLib.attach(paddr);

    const paramLib = await ethers.getContractFactory("Params");
    const paramslib = paramLib.attach(paramaddr);


    const accounts = await ethers.getSigners();

    const deposit = 3000

    let createRound = await group.CreateRound(deposit);
    await createRound.wait();
    console.log("round created");

    for (let i = 0; i < accounts.length; i++) {
        let enter = await group.connect(accounts[i]).Enter({ value: deposit });
        await enter.wait();
        console.log("enter");
    }

    let startRound = await group.StartRound();
    await startRound.wait();
    console.log("round started");



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

    async function IterLot(lotAddr, creatorNumber, ownerNumber, timeF, timeS, value, initPrice) {
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
        console.log("new lot");

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

            let dataProofRes = web3.eth.abi.encodeParameters(
                ['uint256', 'uint256', 'uint256', 'uint256', 'address', 'uint256'],
                [balance, price, Hres, Hd, prevOwner, prevBalance]
            );

            let dataProofEP = web3.eth.abi.encodeParameters(
                ['address', 'uint256', 'uint256'],
                [prevOwner, prevPrice, prevSnapshot]
            );

            await (await group.connect(accounts[i]).BuyLot(lotAddr, dataProofRes, dataProofEP)).wait();
            console.log("buy lot");

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

        let sendTx = await group.SendLot(lotAddr, dataInit);
        await sendTx.wait()
        console.log("send lot");

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

        const receiveTx = await group.ReceiveLot(
            lotAddr,
            accounts[ownerNumber].address,
            dataInit,
            dataProofRes,
            dataParams
        );

        await receiveTx.wait();
        console.log("receive lot");
    }

    const lotTx = await (await group.CreateLot()).wait();
    const lotAddr = lotTx.events[0].args._lotAddr;
    console.log("lot created", lotAddr);

    let timeF = Date.now() + 120;
    let timeS = timeF + 100;
    let value = 65;
    let initPrice = 100;


    let creatorNumber = 0;
    let ownerNumber = 1;

    await IterLot(lotAddr, creatorNumber, ownerNumber, timeF, timeS, value, initPrice);

    timeF = Date.now() + 120;
    timeS = timeF + 100;
    value = 75;
    initPrice = 200;


    creatorNumber = 2;
    ownerNumber = 3;

    await IterLot(lotAddr, creatorNumber, ownerNumber, timeF, timeS, value, initPrice);


}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
