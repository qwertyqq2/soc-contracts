// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./Round.sol";
import "./interfaces/IRound.sol";

import "./libraries/Proof.sol";
import "./libraries/Prize.sol";

import "hardhat/console.sol";

contract Group {

    event LotCreated(
        address _lotAddr
    );

    event NewBalance(
        address _owner,
        uint _newBalance
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
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) external{
        IRound round = IRound(roundAddr);
        round.SendLot(_lotAddr, _timeFirst, _timeSecond, _value);
    }

    function ReceiveLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _addr,
        uint256 _price,
        uint _H,
        uint _balance,
        uint _prevSnap
    ) external {
        Proof.ProofRes memory proof = Proof.NewProof(
            _addr,
            _price,
            _H,
            _balance
        );
        proof.prevSnap = _prevSnap;
        IRound round = IRound(roundAddr);
        uint newBalance = round.ReceiveLot(_lotAddr, _timeFirst, _timeSecond, _value, proof);
        emit NewBalance(_addr, newBalance);
    }

    function CancelLot(
        address _lotAddr,
        uint256 _currentPrice,
        uint _H,
        uint256 _balance,
        address _prevOwner,
        uint256 _prevPrice,
        uint256 _prevSnap
        ) public {
        Proof.ProofRes memory proofRes = Proof.NewProof(msg.sender, _currentPrice, _H, _balance);
        Proof.ProofEnoungPrice memory proofEP = Proof.NewProofEnoughPrice(_prevOwner, _prevPrice, _prevSnap);
        IRound round = IRound(roundAddr);
        round.CancelLot(_lotAddr, proofRes, proofEP);

    }

    function SendCancelLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external {
        IRound round = IRound(roundAddr);
        round.SendCanceled(_lotAddr, _timeFirst, _timeSecond, _value, _sender);
    }

    function ReceiveCancelLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external{
        IRound round = IRound(roundAddr);
        round.ReceiveCanceled(_lotAddr, _timeFirst, _timeSecond, _value, _sender);
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
}
