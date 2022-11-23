async function main() {

    const contract = await ethers.getContractFactory("Group", {
        libraries: {
            Math: "0x4d0D6c49F5dEdA179eD5F729bc9b2FBf67fF3Ac0",
            Proof: "0x70d40C430EFCAF7df1a8a6d0716CA3553e8027cf",
            Params: "0x8F74E84EfCCbDF35Be94c4E97C8064d57b5df0bA",
            JumpSnap: "0x4919bC11E699303ee18062EA655aF6ae5E860DF7"
        },
    });

    const group = contract.attach("0x89e74AFDe268714Ff43Fa62f1e1593f011623698");

    const mathLib = await ethers.getContractFactory("Math");
    const mlib = mathLib.attach("0x4d0D6c49F5dEdA179eD5F729bc9b2FBf67fF3Ac0");

    const pLib = await ethers.getContractFactory("Proof");
    const plib = pLib.attach("0x70d40C430EFCAF7df1a8a6d0716CA3553e8027cf");

    const paramLib = await ethers.getContractFactory("Params");
    const paramslib = paramLib.attach("0x8F74E84EfCCbDF35Be94c4E97C8064d57b5df0bA");


    const accounts = await ethers.getSigners();

    let CreateLotTx = await group.CreateLot();
    let lotTx = await CreateLotTx.wait();
    const lotAddr = lotTx.events[0].args._lotAddr;

    console.log("created lot: ", lotAddr);

    let timeF = Date.now() + 120;
    let timeS = timeF + 100;
    let value = 1000;
    let initPrice = 100;

    const creatorNumber = 2;
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
    Hd = await GetProofPlayerDouble(prevNumber, 1);

    price = initPrice + 100;

    let buyTx = await group.connect(accounts[1]).BuyLot
        (lotAddr, price, Hres, Hd, balance,
            prevBalance, prevOwner, prevPrice, prevSnapshot);
    await buyTx.wait();
    console.log("buy lot");


    balances[creatorNumber] += BigInt(price);
    balances[1] -= price;

    prevSnapshot = snapshot;
    snapshot = await mlib.GetNewBuySnapshot(owner, price, snapshot);


    let dataInit = await paramslib.EncodeInitParams(timeF, timeS, value);

    let sendTx = await group.connect(accounts[0]).SendLot(lotAddr, dataInit);
    await sendTx.wait();
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

    const receiveTx = await group.connect(accounts[0]).ReceiveLot(
        lotAddr,
        accounts[1].address,
        dataInit,
        dataProof,
        dataParams
    );
    const result = await receiveTx.wait();
    console.log("receive lot");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});