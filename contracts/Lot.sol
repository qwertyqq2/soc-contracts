// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./libraries/Proof.sol";
import "./libraries/Params.sol";


import "hardhat/console.sol";


contract Lot {
    address roundAddr;

    uint256 snapshot;
    uint256 snapshot1;


    uint state;

    uint receiveToken;
    uint initBalance;
    
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


    constructor(){
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
    }


    modifier proofInit(
        Params.InitParams calldata init
    ){
        require(snapInit(init.timeFirst, init.timeSecond, init.value) == snapshot1, "Not proof init");
        _;
    }

    modifier proofOwner(Proof.ProofRes calldata proof){
        uint snap = Proof.GetProofOwner(proof);
        require(snap == snapshot, "Not right proof owner");
        _;

    }


    function End(
        Params.InitParams calldata init
        ) public onlyRound proofInit(init) {
        require(block.timestamp> 0, "Not correct time");
        state = uint256(keccak256(abi.encode("wait")));
    }

    function Close(
        Params.InitParams calldata init,
        Proof.ProofRes calldata proof
    ) public onlyRound proofInit(init) proofOwner(proof){
        require(state == uint256(keccak256(abi.encode("wait"))), "not wait");
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

    function SetInitBalance(uint _initBal) external onlyRound{
        require(_initBal>0);
        initBalance = _initBal;
    }

    function GetInitBalance() external view returns(uint){
        return initBalance;
    }

     function GetSnap() external view returns (uint256) {
        return snapshot;
    }


    
}