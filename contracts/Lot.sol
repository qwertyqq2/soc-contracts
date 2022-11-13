// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./interfaces/IExchangeTest.sol";

import "./libraries/Proof.sol";


import "hardhat/console.sol";


contract Lot {
    address roundAddr;
    uint256 numberLot;

    uint256 snapshot;
    uint256 snapshot1;


    uint state;

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
        state = uint256(keccak256(abi.encode("closed")));
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
    ) external onlyRound {
        require(state == uint256(keccak256(abi.encode("closed"))), "Not new");
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

        state = uint256(keccak256(abi.encode("empty")));
        
        emit NewLot(timeFirst, timeSecond, owner, price, value, snapshot);
        console.log("New lot: ", owner, price);
    }


    modifier correctPrice(Proof.ProofEnoungPrice calldata proof, uint newPrice) {
        uint proofSnap = Proof.GetProofEnoughPrice(proof);
        require(proofSnap == snapshot, "Not right previous owner");
        require(newPrice>proof.prevPrice, "New price less than old");
        _;
    }

    function Buy(
        address sender, 
        uint256 newPrice,
        Proof.ProofEnoungPrice calldata proof
        ) external onlyRound correctPrice(proof, newPrice){
        require(state == uint256(keccak256(abi.encode("empty"))), "not empty");
        snapshot = uint256(
            keccak256(
                abi.encodePacked(
                    sender, 
                    newPrice, 
                    snapshot
                )
            )
        );
        emit BuyLot(sender, newPrice, snapshot);
        console.log("Buy lot: ", sender, newPrice);
    }


    modifier proofInit(
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value
    ){
        require(snapInit(timeFirst, timeSecond, value) == snapshot1, "Not proof init");
        _;
    }

    modifier proofOwner(Proof.ProofRes calldata proof){
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
        state = uint256(keccak256(abi.encode("wait")));
    }

    function Close(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes calldata proof
    ) public onlyRound proofInit(_timeFirst, _timeSecond, _value) proofOwner(proof){
        require(state == uint256(keccak256(abi.encode("wait"))), "not wait");
        require(block.timestamp>0, "Not correct time");
        state = uint256(keccak256(abi.encode("closed")));
    }



    modifier correctCancel(Proof.ProofEnoungPrice calldata proof){
        uint proofSnap = Proof.GetProofEnoughPrice(proof);
        require(proofSnap == snapshot, "Not right previous owner");
        _;
    }

    function Cancel(
        address _sender,
        uint _price,
        Proof.ProofEnoungPrice calldata proof
    ) public onlyRound correctCancel(proof){
        require(_price == proof.prevPrice, "Not correct price");
        state = uint256(keccak256(abi.encodePacked("canceled", _sender)));
    }

    function EndCancel(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
        ) public onlyRound proofInit(_timeFirst, _timeSecond, _value) {
        require(state == uint256(keccak256(abi.encodePacked("canceled", _sender))));
        require(block.timestamp> 0, "Not correct time");
        state = uint256(keccak256(abi.encodePacked("wait canceled", _sender)));
    }

    function CloseCancel(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) public onlyRound proofInit(_timeFirst, _timeSecond, _value){
        require(state == uint256(keccak256(abi.encodePacked("wait canceled", _sender))));
        require(block.timestamp>0, "Not correct time");
        state = uint256(keccak256(abi.encode("closed")));
    }



    function snapInit(
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value
    ) private pure returns(uint256){
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


    function SetReceiveTokens(uint _receiveTokens) external onlyRound{
        require(_receiveTokens>0, "uncorrect value");
        receiveToken = _receiveTokens;
    }

    function GetReceiveTokens() external view returns(uint){
        return receiveToken;
    }

     function GetSnap() external view returns (uint256) {
        return snapshot;
    }


    
}