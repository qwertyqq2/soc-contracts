// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IExchangeTest.sol";

import "./libraries/Proof.sol";


import "hardhat/console.sol";


contract Lot {
    address roundAddr;
    uint256 numberLot;

    uint256 snapshot;
    uint256 snapshot1;

    uint256 lastCommit;

    bool exist = true;
    bool wait = false;

    uint receiveToken;
    
    event NewLot(
        uint256 timeFirst,
        uint256 timeSecond,
        address owner,
        uint256 price,
        uint256 value,
        uint256 hash
    );

    event BuyLot(address owner, uint256 price, uint256 hash);

    event JoinLot(address sender, uint256 price, uint256 hash);

    event FinalLot(address owner, uint256 value);


    constructor(uint256 num ) {
        numberLot = num;
        roundAddr = msg.sender;
    }

    modifier onlyRound() {
        require(msg.sender == roundAddr, "It`s not a round contract!");
        _;
    }

    function New(
        uint256 timeFirst,
        uint256 timeSecond,
        address owner,
        uint256 price,
        uint256 value
    ) public onlyRound {
        lastCommit = block.timestamp;
        snapshot = uint256(
            keccak256(
                abi.encodePacked(
                    owner, 
                    price, 
                    uint(0)
                )
            )
        );

        snapshot1 = uint256(
            keccak256(
                abi.encodePacked(
                    timeFirst, 
                    timeSecond, 
                    value
                )
            )
        );

        
        emit NewLot(timeFirst, timeSecond, owner, price, value, snapshot);
        //console.log("New lot: ", owner, price);
    }


    modifier correctPrice(Proof.ProofEnoungPrice memory proof, uint newPrice) {
        uint proofSnap = Proof.GetProofEnoughPrice(proof);
        require(proofSnap == snapshot, "Not right previous owner");
        require(newPrice>proof.prevPrice, "New price less than old");
        _;
    }

    function Buy(
        address sender, 
        uint256 newPrice,
        Proof.ProofEnoungPrice memory proof
        ) public onlyRound correctPrice(proof, newPrice){
        require(exist == true, "Already not exist");
        require(block.timestamp + lastCommit> 10, "Early");
        snapshot = uint256(
            keccak256(
                abi.encodePacked(
                    sender, 
                    newPrice, 
                    snapshot
                )
            )
        );
        if (newPrice <= 0) {
            exist = false;
        }
        lastCommit = block.timestamp;
        emit BuyLot(sender, newPrice, snapshot);
        console.log("Buy lot: ", sender, newPrice);
    }


    function Join(
        address sender, 
        uint256 rate
        ) public onlyRound{
        require(exist, "Already not exist");
        require(rate > 0, "Not ehoung rate!");
        snapshot = uint256(
            keccak256(
                abi.encodePacked(
                    sender, 
                    rate, 
                    snapshot
                )
            )
        );

        emit JoinLot(sender, rate, snapshot);
        //console.log("Join lot: ", sender, rate);
    }


    modifier proofInit(
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value
    ){
        require(snapInit(timeFirst, timeSecond, value) == snapshot1, "Not proof init");
        _;
    }

    modifier proofOwner(Proof.ProofRes memory proof){
        uint snap = Proof.GetProofOwner(proof);
        require(snap == snapshot, "Not right proof owner");
        _;

    }
    function End(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
        ) public onlyRound proofInit(_timeFirst, _timeSecond, _value) {
        require(block.timestamp> 0, "Not correct time");
        wait = true;
    }

    function SetReceiveTokens(uint _receiveTokens) public onlyRound{
        require(_receiveTokens>0, "uncorrect value");
        receiveToken = _receiveTokens;
    }

    function GetReceiveTokens() public view returns(uint){
        return receiveToken;
    }


    function Close(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes memory proof
    ) public onlyRound proofInit(_timeFirst, _timeSecond, _value) proofOwner(proof){
        require(wait == true, "not wait");
        require(block.timestamp>0);
        exist = false;
    }



    function snapInit(
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value
    ) public pure returns(uint256){
        return uint256(
                keccak256(
                    abi.encodePacked(
                        timeFirst, 
                        timeSecond, 
                        value
                    )
                )
            );
    }


     function GetSnap() public view returns (uint256) {
        return snapshot;
    }


    
}