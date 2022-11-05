// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Round.sol";
import "./interfaces/IRound.sol";

import "./libraries/Proof.sol";
import "./libraries/Player.sol";

import "hardhat/console.sol";

contract Group {
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
        uint256 _balance
        ) public {
        Proof.ProofRes memory proof = Proof.NewProof(msg.sender, _price, _H1, _H2, _balance);
        IRound round = IRound(roundAddr);
        round.BuyLot(proof);
    }

    function JoinLot(
        uint256 _price,
        uint _H1, 
        uint _H2, 
        uint256 _balance
    ) public{
        Proof.ProofRes memory proof = Proof.NewProof(msg.sender, _price, _H1, _H2, _balance);
        IRound round = IRound(roundAddr);
        round.JoinLot(proof);
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
        round.ReceiveLot(_timeFirst, _timeSecond, _value, proof);
    }

    

    function TryVerifyFull(
    address[] calldata _owners, 
    uint256[] calldata _prices,
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    )
     public view{
        IRound round = IRound(roundAddr);
        round.VerifyFull(_owners, _prices, _timeFirst, _timeSecond, _value);
    }

    
    function TryVerifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices, 
        address[] memory _support,
        uint256[] memory _additives,
        uint256[] memory _sizes,
        uint256 _snap
    ) public view{
        IRound round = IRound(roundAddr);
        round.VerifyOwner(_owners, _prices, _support, _additives, _sizes, _snap);
    }


    function Correct(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256[] memory _sizes,
        uint256 _snap
    ) public{
        IRound round = IRound(roundAddr);
        round.CorrectOwner(_owners, _prices, _support, _additives, _sizes, _snap);
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
}
