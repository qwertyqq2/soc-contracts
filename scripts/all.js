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
    let create = await createTx.wait();

    console.log("new round:");
    console.log("data: ", create.events[0].args._roundAddress);


    for (let i = 0; i < accounts.length; i++) {
        let enterTx = await group.connect(accounts[i]).Enter({ value: deposit });
        let enter = await enterTx.wait();
        console.log("enter!");
    }

    let startRoundTx = await group.StartRound();
    let start = await startRoundTx.wait();

    console.log("Round started!");

    let CreateLotTx = await group.CreateLot();
    let lotTx = await CreateLotTx.wait();
    const lotAddr = lotTx.events[4].args._lotAddr;

    console.log("created lot");
    console.log("data: ", lotAddr);

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
    let newLot = await newLotTx.wait();
    console.log("new lot");
    console.log("data: ", newLot.events[0].args._lotAddr,
        newLot.events[5].args._lotAddr,
        newLot.events[5].args._timeFirst,
        newLot.events[5].args._timeSecond,
        newLot.events[5].args._price,
        newLot.events[5].args._val,
        newLot.events[5].args._lotSnap,
        newLot.events[5].args._bsnap);

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
    let buy = await buyTx.wait();
    console.log("buy lot");
    console.log("data: ", buy.events[6].args._lotAddr,
        buy.events[6].args._lotAddr,
        buy.events[6].args._sender,
        buy.events[6].args._price,
        buy.events[6].args._lotSnap,
        buy.events[6].args._bsnap);


    balances[creatorNumber] += Number(price);
    balances[1] -= Number(price);


    prevSnapshot = snapshot;
    snapshot = await mlib.GetNewBuySnapshot(accounts[1].address, price, snapshot);


    let dataInit = await paramslib.EncodeInitParams(timeF, timeS, value);



    let sendTx = await group.connect(accounts[0]).SendLot(lotAddr, dataInit);
    let send = await sendTx.wait();
    console.log("send lot");
    console.log("data: ", send.events[7].args._lotAddr,
        send.events[7].args._receiveTokens);

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
    console.log("data1: ", result.events[0].args._owner,
        result.events[8].args._nwin,
        result.events[8].args._n,
        result.events[8].args._spos,
        result.events[8].args._sneg);
    console.log("data2: ", result.events[1].args._owner,
        result.events[9].args._lotAddr,
        result.events[9].args._owner,
        result.events[9].args._balance,
        result.events[9].args._psnap,
        result.events[9].args._bsnap);

    console.log("\n\n End");

}

function sleepFor(sleepDuration) {
    var now = new Date().getTime();
    while (new Date().getTime() < now + sleepDuration) {
    }
}

function sleepThenAct() {
    sleepFor(20000);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

//balance:  [ BigNumber { value: "11949" }, BigNumber { value: "0" } ]
