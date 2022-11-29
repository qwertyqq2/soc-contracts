async function main() {
    const accounts = await ethers.getSigners();
    const maddr = "0xfc767640379e558D835e641dEBBDAd9B9Dc54798"
    const paddr = "0x0b1Fe1fed251bE5f1aD0195cFCdd5B98c1396e3D"
    const paramaddr = "0x3559D1FbCA502088944aEAdb65E633a168066c2a"
    const jumpaddr = "0x37521E4854712448380a4FFfA6c005c431573946"
    const groupaddr = "0x69ff2e622861947876eD40BCaE4eC7c4396C59F3"
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

    let CreateLotTx = await group.CreateLot();
    let lotTx = await CreateLotTx.wait();
    lotAddr = lotTx.events[0].args._lotAddr;

    console.log("lot created");


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

    let newlot = await group.connect(accounts[creatorNumber]).NewLot(lotAddr, timeF, timeS,
        initPrice, value, H, balances[creatorNumber]);
    await newlot.wait();
    console.log("new lot");

    balances[creatorNumber] -= Number(initPrice);

    let snapshot = await mlib.GetNewBuySnapshot(accounts[creatorNumber].address, initPrice, 0);

    let prevSnapshot = 0;

    Hres = await GetProofPlayer(1);
    Hd = await GetProofPlayerDouble(creatorNumber, 1);

    let price = initPrice;
    let prevPrice = price;
    price = initPrice + 100;

    let buylot = await group.connect(accounts[1]).BuyLot
        (lotAddr, price, Hres, Hd, balances[1],
            balances[creatorNumber], accounts[creatorNumber].address, prevPrice, prevSnapshot);
    buylot.wait();
    console.log("buy lot");

    balances[creatorNumber] += Number(price);
    balances[1] -= Number(price);

    prevSnapshot = snapshot;
    snapshot = await mlib.GetNewBuySnapshot(accounts[1].address, price, snapshot);

    let dataInit = await paramslib.EncodeInitParams(timeF, timeS, value);

    let sendlot = await group.connect(accounts[0]).SendLot(lotAddr, dataInit);
    await sendlot.wait();
    console.log("send lot");



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

    let receivelot = await group.connect(accounts[0]).ReceiveLot(
        lotAddr,
        accounts[1].address,
        dataInit,
        dataProof,
        dataParams
    );
    await receivelot.wait();
    console.log("receive lot");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
