// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./Round.sol";
import "./interfaces/IRound.sol";

import "./libraries/Proof.sol";
import "./libraries/Prize.sol";

import "hardhat/console.sol";

contract Group {

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

    modifier onlyPlayer() {
        IRound round = IRound(roundAddr);
        require(round.GetPlayer(msg.sender) > 0, "You're not a player");
        _;
    }

    function CreateLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _price,
        uint256 _val,
        uint256 _H1, 
        uint256 _H2, 
        uint _balance
    ) public {
        Proof.ProofRes memory proof = Proof.NewProof(msg.sender, _price, _H1, _H2, _balance);
        IRound round = IRound(roundAddr);
        round.NewLot(_timeFirst, _timeSecond, _val, proof);
    }

    function BuyLot(
        uint256 _price,
        uint _H1,
        uint _H2,
        uint256 _balance,
        address _prevOwner,
        uint256 _prevPrice,
        uint256 _prevSnap
        ) public {
        Proof.ProofRes memory proofRes = Proof.NewProof(msg.sender, _price, _H1, _H2, _balance);
        Proof.ProofEnoungPrice memory proofEP = Proof.NewProofEnoughPrice(_prevOwner, _prevPrice, _prevSnap);
        IRound round = IRound(roundAddr);
        round.BuyLot(proofRes, proofEP);
    }


    function SendLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public{
        IRound round = IRound(roundAddr);
        round.SendLot(_timeFirst, _timeSecond, _value);
    }

    function ReceiveLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _addr,
        uint256 _price,
        uint _H1,
        uint _H2,
        uint _balance,
        uint _prevSnap
    ) public {
        Proof.ProofRes memory proof = Proof.NewProof(
            _addr,
            _price,
            _H1,
            _H2,
            _balance
        );
        proof.prevSnap = _prevSnap;
        IRound round = IRound(roundAddr);
        uint newBalance = round.ReceiveLot(_timeFirst, _timeSecond, _value, proof);
        emit NewBalance(_addr, newBalance);
    }

    function CancelLot(
        uint256 _currentPrice,
        uint _H1,
        uint _H2,
        uint256 _balance,
        address _prevOwner,
        uint256 _prevPrice,
        uint256 _prevSnap
        ) public {
        Proof.ProofRes memory proofRes = Proof.NewProof(msg.sender, _currentPrice, _H1, _H2, _balance);
        Proof.ProofEnoungPrice memory proofEP = Proof.NewProofEnoughPrice(_prevOwner, _prevPrice, _prevSnap);
        IRound round = IRound(roundAddr);
        round.CancelLot(proofRes, proofEP);

    }

    function SendCancelLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external {
        IRound round = IRound(roundAddr);
        round.SendCanceled(_timeFirst, _timeSecond, _value, _sender);
    }

    function ReceiveCancelLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external{
        IRound round = IRound(roundAddr);
        round.ReceiveCanceled(_timeFirst, _timeSecond, _value, _sender);
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

    function GetBalance() public view returns(uint256){
        return address(this).balance;
    }

    function VerifyProofRes(
        address _addr,
        uint _H1,
        uint _H2,
        uint _balance
    ) public view returns(bool){
        Proof.ProofRes memory proofRes = Proof.NewProof(_addr, 0, _H1, _H2, _balance);
        IRound round = IRound(roundAddr);
        return round.VerifyProofRes(proofRes);
    }
}
