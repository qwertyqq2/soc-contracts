// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./interfaces/IGroup.sol";
import "./interfaces/IExchangeTest.sol";
import "./interfaces/ILot.sol";
import "./interfaces/IRound.sol";


import "./libraries/Proof.sol";
import "./libraries/Math.sol";
import "./libraries/JumpSnap.sol";
import "./libraries/Params.sol";


import "./ExchangeTest.sol";
import "./Lot.sol";

import "hardhat/console.sol";

contract Round {
    address addr;

    mapping(address => uint256) players;
    uint256 timeCreation;
    address groupAddress;
    mapping(address => uint256) pendingPlayers;
    address[] pendingAddress;
    address exchangeAddress;
    uint256 deposit;

    address lotAddr;

    uint256 balancesSnap = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 paramsSnap = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    uint Spos = 0;
    uint Sneg = 0;

    constructor(uint256 _deposit) {
        groupAddress = msg.sender;
        deposit = _deposit;
        addr = address(this);
        ExchangeTest exc = new ExchangeTest();
        exchangeAddress = address(exc);
    }

    event SendLotEvent(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    );

    event ReceiveLotEvent(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        uint256 delta
    );


    
    fallback() external payable {}

    receive() external payable {}

    modifier onlyGroup() {
        require(msg.sender == groupAddress, "It`s not a group contract!");
        _;
    }

    function Enter(address _sender, uint256 _value) public onlyGroup {
        require(_value >= deposit, "Not enouth deposit");
        pendingPlayers[_sender] += _value;
        pendingAddress.push(_sender);
    }

    modifier onlyOwner() {
        IGroup group = IGroup(groupAddress);
        address own = group.GetOwner();
        require(msg.sender == own, "You`re not owner group");
        _;
    }

    function StartRound() public onlyGroup {
        uint8 i=0;
        for (i = 0; i < pendingAddress.length; i++) {
            balancesSnap = Math.xor(balancesSnap, uint256(
                                                    keccak256(abi.encodePacked(
                                                        uint256(uint160(pendingAddress[i])), 
                                                        deposit
                                                        )))
                                        );          
            uint psnap = Params.GetSnapParamPlayerOut(pendingAddress[i], deposit, 0, 0, 0, 0);
            paramsSnap = Math.xor(psnap, paramsSnap);
        }
        balancesSnap = uint256(keccak256(abi.encode(balancesSnap)));
        paramsSnap = uint256(keccak256(abi.encode(paramsSnap)));
        timeCreation = block.timestamp;
    }

    function CreateLot() external onlyGroup returns(address){
        require(timeCreation!=0);
        Lot lot  = new Lot();
        lotAddr = address(lot);
        return lotAddr;
    }

    
    modifier enoughRes(Proof.ProofRes calldata proof){
        uint res = Proof.GetProofBalance(proof);
        require(res == balancesSnap, "Not proof");
        require(proof.price<=proof.balance, "Not enoung res");
        _;
    }

    function NewLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes calldata proof
    ) public onlyGroup enoughRes(proof) {
        balancesSnap = JumpSnap.SnapNew(proof.owner, proof.balance, proof.price, proof.Hres);
        ILot lot = ILot(_lotAddr);
        lot.New(_timeFirst, _timeSecond, proof.owner, proof.price, _val);
    }

    function BuyLot(
        address _lotAddr,
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP 
     ) public onlyGroup enoughRes(proofRes) {
        balancesSnap = JumpSnap.SnapBuy(
            proofRes.owner,
            proofRes.prevOwner,
            proofRes.balance,
            proofRes.prevBalance,
            proofRes.price,
            proofRes.Hd
        );
        ILot lot = ILot(_lotAddr);
        lot.Buy(proofRes.owner, proofRes.price, proofEP);
    }

    

    function SendLot(
        address _lotAddr,
        Params.InitParams memory initParams
    ) public onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
        lot.End(initParams);

        lot.SetInitBalance(address(this).balance);
        uint initBal = exc.GetTokenBalance();
        exc.EthToToken{value: initParams.value}();
        lot.SetReceiveTokens(exc.GetTokenBalance() - initBal);
        
        console.log("Lot sent ");
    }

    function GetSnapParamPlayer( 
        address _owner,
        uint _balance,
        uint _nwin,
        uint _n,
        uint _spos,
        uint _sneg 
        ) public pure returns(uint){
            return uint(keccak256(abi.encodePacked(_owner, _balance, _nwin, _n, _spos, _sneg)));
        }

    // function updatePlus(
    //     Params.PlayerParams calldata _params,
    //     uint _Spos,
    //     uint _delta,
    //     uint _price
    //     ) private view returns(uint, uint){
    //         uint s_ = (_params.spos + _delta)*100/_Spos;
    //         uint d_ = (1000000 - (_params.balance + _price))*s_/100;
    //         uint curbalance = _params.balance + _price + d_;
    //         console.log("newBalance: ", curbalance);
    //         return (GetSnapParamPlayer(_params.owner, curbalance, _params.nwin +1, 
    //             _params.n +1, _params.spos + _delta, _params.sneg), curbalance);
    //     }


        function updatePlus(
        Params.PlayerParams calldata _params,
        uint _delta,
        uint _price
        ) private view returns(uint, uint){
            uint curbalance = _params.balance + _price + 3*_delta;
            console.log("newBalance: ", curbalance);
            return (GetSnapParamPlayer(_params.owner, curbalance, _params.nwin +1, 
                _params.n +1, _params.spos + _delta, _params.sneg), curbalance);
        }

    function updateMinus(
        Params.PlayerParams calldata _params,
        uint _delta
        ) private view returns(uint, uint){
            uint curbalance = _params.balance - 3*_delta;
            console.log("newBalance: ", curbalance);
            return (GetSnapParamPlayer(_params.owner, curbalance, _params.nwin, 
                _params.n +1, _params.spos, _params.sneg + _delta), curbalance);
    }

    modifier correctParams(Params.PlayerParams memory _params){
        uint snap = Params.GetSnapParamPlayer(_params);
        uint val = Math.xor(_params.Hp, snap);
        require(uint(keccak256(abi.encode(val)))==paramsSnap, "Not correct params");
        _;
    }
    function ReceiveLot(
        address _lotAddr,
        Params.InitParams calldata _init,
        Proof.ProofRes calldata _proof,
        Params.PlayerParams calldata _params
    )  public onlyGroup correctParams(_params) returns(uint newBalance){
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
        lot.Close(_init, _proof);
        uint initBal = address(this).balance;
        uint val = exc.GetTokenBalance();
        exc.TokenToEth(val);
        int res = int(address(this).balance) - int(initBal) - int(_init.value);

        uint snapParams;
        res = int(10);

        if(res>=0){            
            (snapParams, newBalance) = updatePlus(
                _params, 
                uint(res), 
                _proof.price);

            balancesSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _proof.Hres, 
                            uint256(keccak256(abi.encodePacked(uint256(uint160(_params.owner)),  newBalance)))
                            ))));


            paramsSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _params.Hp, 
                            snapParams
                            ))));
        }
        else{
            (snapParams, newBalance) = updateMinus(
                _params, 
                uint(Math.Abs(res))
                );

            balancesSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _proof.Hres, 
                            uint256(keccak256(abi.encodePacked(uint256(uint160(_params.owner)),  newBalance)))
                            ))));


            paramsSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _params.Hp, 
                            snapParams
                            ))));

        }
        console.log("Lot received");
    }



    function GetSnap() public view returns (uint256) {
        ILot lot = ILot(lotAddr);
        return lot.GetSnap();
    }

    function GetBalance() public view returns (uint256) {
        return addr.balance;
    }
    
    function GetSnapshot() public view returns(uint256){
        return balancesSnap;
    }

    function GetInitSnap() public pure returns(uint256){
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }

    function GetExchange() public view returns(address){
        return exchangeAddress;
    }

    function VerifyProofRes(
        Proof.ProofRes calldata proof
    ) external view returns(bool){
        uint snap = Proof.GetProofBalance(proof);
        return snap==balancesSnap;
    }

    function VerifyParamsPlayer(
        Params.PlayerParams calldata _params
    ) external view returns(bool){
        uint snap = Params.GetSnapParamPlayer(_params);
        uint val = Math.xor(_params.Hp, snap);
        return uint(keccak256(abi.encode(val))) == paramsSnap;
    }

    function GetParamsSnapshot() external view returns(uint){
        return paramsSnap;
    }
}
