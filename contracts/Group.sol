// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./Round.sol";
import "./interfaces/IRound.sol";

import "./libraries/Proof.sol";
import "./libraries/JumpSnap.sol";

import "hardhat/console.sol";

contract Group {

    event LotCreated(
        address _lotAddr
    );

    event NewBalance(
        address _owner,
        uint _newBalance
    );

    event UpdatePlayerParams(
        address _owner,
        uint _nwin, 
        uint _n,
        uint _spos, 
        uint _sneg
    );

    address owner;
    address roundAddr;
    address exchangeAddress;

    constructor() {
        owner = msg.sender;
    }

    function GetOwner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You`re not the owner");
        _;
    }

    function CreateRound(uint256 _deposit) public onlyOwner{
        Round round = new Round(_deposit);
        roundAddr = address(round);
    }

    function Enter() public payable {
        IRound round = IRound(roundAddr);
        round.Enter(msg.sender, msg.value);
        payable(roundAddr).transfer(msg.value);
    }

    function StartRound() public {
        IRound round = IRound(roundAddr);
        round.StartRound();
    }

    function CreateLot() external{
        IRound round = IRound(roundAddr);
        address lotAddr = round.CreateLot();
        emit LotCreated(lotAddr);
        console.log("Create Lot: ", lotAddr);
    }

    modifier onlyPlayer() {
        IRound round = IRound(roundAddr);
        require(round.GetPlayer(msg.sender) > 0, "You're not a player");
        _;
    }

    function NewLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _price,
        uint256 _val,
        uint _Hres,
        uint _balance
    ) external {
        Proof.ProofRes memory proof = Proof.NewProof(msg.sender, _price, _Hres, _balance);
        IRound round = IRound(roundAddr);
        round.NewLot(_lotAddr, _timeFirst, _timeSecond, _val, proof);
    }

    function BuyLot(
        address _lotAddr,
        uint256 _price,
        uint _Hres,
        uint _Hd,
        uint256 _balance,
        uint256 _prevBalance,
        address _prevOwner,
        uint256 _prevPrice,
        uint256 _prevSnap
        ) external {
        Proof.ProofRes memory proofRes = Proof.NewProof(msg.sender, _price, _Hres, _balance);
        proofRes.prevOwner = _prevOwner;
        proofRes.prevBalance = _prevBalance;
        proofRes.Hd = _Hd;
        Proof.ProofEnoungPrice memory proofEP = Proof.NewProofEnoughPrice(_prevOwner, _prevPrice, _prevSnap);
        IRound round = IRound(roundAddr);
        round.BuyLot(_lotAddr, proofRes, proofEP);
    }


    function SendLot(
        address _lotAddr,
        bytes memory initParamsData
    ) external{
        Params.InitParams memory initParams = Params.DecodeInitParams(initParamsData);
        IRound round = IRound(roundAddr);
        round.SendLot(_lotAddr, initParams);
    }

    function ReceiveLot(
        address _lotAddr,
        address _owner,
        bytes memory initParamsData,
        bytes memory proofResData,
        bytes memory playerParamsData
    ) external returns (uint newBalance){
        Params.InitParams memory initParams = Params.DecodeInitParams(initParamsData);
        Proof.ProofRes memory proof = Proof.DecodeProofRes(proofResData);
        proof.owner = _owner;
        Params.PlayerParams memory params = Params.DecodePlayerParams(playerParamsData);
        IRound round = IRound(roundAddr);
        bytes memory newParamsData;
        (newBalance, newParamsData) = round.ReceiveLot(_lotAddr, initParams, proof, params);
        Params.PlayerParams memory NewParams = Params.DecodePlayerParamsInTuple(newParamsData);
        emit UpdatePlayerParams(
            NewParams.owner, 
            NewParams.nwin,
            NewParams.n,
            NewParams.spos,
            NewParams.sneg);
        emit NewBalance(_owner, newBalance);
    }


    function GetSnap() public view returns (uint256) {
        IRound round = IRound(roundAddr);
        return round.GetSnap();
    }

    function GetRound() public view returns(address){
        return roundAddr;
    }

    function GetSnapRound() public view returns(uint256){
        IRound round = IRound(roundAddr);
        return round.GetSnapshot();
    }

    function GetInitSnapRound() public view returns(uint256){
        IRound round = IRound(roundAddr);
        return round.GetInitSnap();
    }

    function VerifyProofRes(
        address _addr,
        uint _H,
        uint _balance
    ) public view returns(bool){
        Proof.ProofRes memory proofRes = Proof.NewProof(_addr, 0, _H, _balance);
        IRound round = IRound(roundAddr);
        return round.VerifyProofRes(proofRes);
    }

    function VerifyParamsPlayer(
        bytes memory playerParamsData
    ) external view returns(bool){
        Params.PlayerParams memory params = Params.DecodePlayerParams(playerParamsData);
        IRound round = IRound(roundAddr);
        return round.VerifyParamsPlayer(params);
    }

    function GetParamsSnapshot() external view returns(uint){
        IRound round = IRound(roundAddr);
        return round.GetParamsSnapshot();
    }

}  
