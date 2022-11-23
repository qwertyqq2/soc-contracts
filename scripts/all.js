async function main() {
    const mathLib = await ethers.getContractFactory("Math");
    const mlib = await mathLib.deploy();
    await mlib.deployed();
    console.log("Math address: ", mlib.address);


    const proofLib = await ethers.getContractFactory("Proof");
    const plib = await proofLib.deploy();
    await plib.deployed();
    console.log("Proof address: ", plib.address);

    const paramsLib = await ethers.getContractFactory("Params");
    const paramslib = await paramsLib.deploy();
    await paramslib.deployed();
    console.log("Params address: ", paramslib.address);

    const jumpLib = await ethers.getContractFactory("JumpSnap");
    const jumplib = await jumpLib.deploy();
    await jumplib.deployed();
    console.log("JumpSnap address: ", jumplib.address)


    Group = await ethers.getContractFactory("Group", {
        libraries: {
            Math: mlib.address,
            Proof: plib.address,
            Params: paramslib.address,
            JumpSnap: jumplib.address
        },
    });

    group = await Group.deploy()

    console.log("Group created, address:", group.address);

    const accounts = await ethers.getSigners();

    const deposit = 3000

    const createTx = await group.CreateRound(deposit);
    await createTx.wait();

    console.log("new round:", await group.GetRound());

    for (let i = 0; i < accounts.length; i++) {
        let enter = await group.connect(accounts[i]).Enter({ value: deposit });
        await enter.wait();
        console.log("enter!");
    }

    await group.StartRound();

    console.log("Round started!");


    let CreateLotTx = await group.CreateLot();
    let lotTx = await CreateLotTx.wait();
    const lotAddr = lotTx.events[0].args._lotAddr;

    console.log("created lot: ", lotAddr);

    let timeF = Date.now() + 120;
    let timeS = timeF + 100;
    let value = 1000;
    let initPrice = 100;

    const creatorNumber = 0;
    balances = [];
    for (let i = 0; i < accounts.length; i++) {
        balances.push(3000);
    }

    params = [];
    for (let i = 0; i < accounts.length; i++) {
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
        let H = await group.GetInitSnapRound();
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
        let H = await group.GetInitSnapRound();
        let snap;
        for (let i = 0; i < accounts.length; i++) {
            if (i != CurrentNumber) {
                snap = await mlib.GetSnap(accounts[i].address, balances[i]);
                H = await mlib.xor(H, snap);
            }
        }
        return H;
    }

    async function GetProofPlayerDouble(prevnumber, curnumber) {
        let H = await group.GetInitSnapRound();
        for (let i = 0; i < accounts.length; i++) {
            if (i != prevnumber && i != curnumber) {
                snap = await mlib.GetSnap(accounts[i].address, balances[i]);
                H = await mlib.xor(H, snap);
            }
        }
        return H;
    }

    let H = await GetProofPlayer(creatorNumber);

    let newLotTx = await group.connect(accounts[creatorNumber]).NewLot(lotAddr, timeF, timeS,
        initPrice, value, H, balances[creatorNumber]);
    await newLotTx.wait();
    console.log("new lot");

    balances[creatorNumber] -= Number(initPrice);


    let snapshot = await mlib.GetNewBuySnapshot(accounts[creatorNumber].address, initPrice, 0);

    let prevSnapshot = 0;

    Hres = await GetProofPlayer(1);
    Hd = await GetProofPlayerDouble(creatorNumber, 1);

    let price = initPrice;
    let prevPrice = price;
    price = initPrice + 100;

    let buyTx = await group.connect(accounts[1]).BuyLot
        (lotAddr, price, Hres, Hd, balances[1],
            balances[creatorNumber], accounts[creatorNumber].address, prevPrice, prevSnapshot);
    await buyTx.wait();
    console.log("buy lot");


    balances[creatorNumber] += Number(price);
    balances[1] -= Number(price);

    console.log(balances);

    prevSnapshot = snapshot;
    snapshot = await mlib.GetNewBuySnapshot(accounts[1].address, price, snapshot);


    let dataInit = await paramslib.EncodeInitParams(timeF, timeS, value);

    console.log("balance: ", await group.GetDepositRound());


    let sendTx = await group.connect(accounts[0]).SendLot(lotAddr, dataInit);
    let send = await sendTx.wait();
    console.log("send lot");

    console.log("balance: ", await group.GetDepositRound());

    const receiveTokens = await group.GetReceiveRoken(lotAddr);
    console.log("receive tokens: ", receiveTokens);


    //const amountOut = send.events[0].args._amountOut;

    //console.log("amountOut:", amountOut);

    sleepThenAct();


    Hres = await GetProofPlayer(1);
    Hp = await GetProofParams(1);


    const dataProof = await plib.EncodeProofRes(balances[1], price, Hres, prevSnapshot);


    Hp = await GetProofParams(1);

    dataParams = await paramslib.EncodePlayerParams(
        params[1].owner,
        params[1].nwin,
        params[1].n,
        params[1].spos,
        params[1].sneg,
        Hp
    );

    const receiveTx = await group.connect(accounts[0]).ReceiveLot(
        lotAddr,
        accounts[1].address,
        dataInit,
        dataProof,
        dataParams
    );
    const result = await receiveTx.wait();
    console.log("receive lot");


    console.log("balance: ", await group.GetDepositRound());

}

function sleepFor(sleepDuration) {
    var now = new Date().getTime();
    while (new Date().getTime() < now + sleepDuration) {
    }
}

function sleepThenAct() {
    sleepFor(2000);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

//balance:  [ BigNumber { value: "11993" }, BigNumber { value: "0" } ]
//balance:  [ BigNumber { value: "11000" }, BigNumber { value: "2715" } ]