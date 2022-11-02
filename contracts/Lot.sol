// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IRound.sol";
import "./interfaces/IPlayer.sol";
import "hardhat/console.sol";


contract Lot {
    address roundAddr;
    uint256 numberLot;

    uint256 snapshot;
    uint256 snapshot1;

    uint256 lastCommit;

    bool exist = true;

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

    modifier onlyRound() {
        require(msg.sender == roundAddr, "It`s not a round contract!");
        _;
    }

    constructor(uint256 num) {
        numberLot = num;
        roundAddr = msg.sender;
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
                abi.encodePacked(timeFirst, timeSecond, owner, price, value)
            )
        );
        emit NewLot(timeFirst, timeSecond, owner, price, value, snapshot);
    }


    function Buy(address sender, uint256 newPrice) public onlyRound {
        require(exist == true, "Already not exist");
        require(block.timestamp + lastCommit> 10, "Early");
        snapshot = uint256(
            keccak256(abi.encodePacked(sender, newPrice, snapshot))
        );
        if (newPrice <= 0) {
            exist = false;
        }
        lastCommit = block.timestamp;
        emit BuyLot(sender, newPrice, snapshot);
    }


    function Join(address sender, uint256 rate) public onlyRound{
        require(exist, "Already not exist");
        require(rate > 0, "Not ehoung rate!");
        snapshot = uint256(
            keccak256(abi.encodePacked(sender, rate, snapshot))
        );

        emit JoinLot(sender, rate, snapshot);
    }


    function verifyFull(
    address[] calldata _owners, 
    uint256[] calldata _prices, 
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) public  view onlyRound{
        require(exist == true, "Already not exist");
        console.log("Verify Full");

        uint256 _snapPoint = uint256(
            keccak256(
                abi.encodePacked(_timeFirst, _timeSecond, _owners[0], _prices[0], _value)
            )
        );

        for(uint i=1;i<_owners.length;i++){
            _snapPoint = uint256(
                keccak256(abi.encodePacked(_owners[i], _prices[i], _snapPoint))
            );
        }
        require(_snapPoint == snapshot, "Not right verify");

    }


    function verifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes,
        uint256 _snap
        ) public view{
        console.log("Verify Owner");
        uint counter;

        for(uint i=0;i<_owners.length;i++){
            _snap = uint256(
                keccak256(abi.encodePacked(_owners[i], _prices[i], _snap))
            );

            for(uint j = counter;j< counter+_sizes[i]; j++){
                _snap = uint256(
                    keccak256(abi.encodePacked(_support[j], _additives[j], _snap))
                );
            }
            counter+=_sizes[i];
        }
        require(_snap == snapshot, "Not right verify");
        require(_prices[0]>_prices[1], "No mistake");
    }


    function CorrectOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes,
        uint256 _snap
        ) public{
        verifyOwner(_owners, _prices, _support, _additives, _sizes, _snap);
        snapshot = _snap;
        console.log("Snapshot is change");
    }



    function calcJoin(
        address[] memory _support, 
        uint256[] memory _additives, 
        uint256 _snapBuy
    ) public pure returns(uint256){
        for(uint i=0;i<_support.length;i++){
            _snapBuy = uint256(
                keccak256(abi.encodePacked(_support[i], _additives[i], _snapBuy))
            );
        }
        return _snapBuy;
    }

    function EndLot(
        address[] memory _senders,
        uint256[] memory _prices,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        uint256 _countSend
    ) public onlyRound {
        require(block.timestamp > _timeFirst - 30, "Not enought time");

        emit FinalLot(_senders[_countSend - 1], _value);

        snapshot1 = uint256(
            keccak256(
                abi.encodePacked(
                    _senders[_countSend - 1],
                    _prices[_countSend - 1],
                    _timeFirst,
                    _timeSecond,
                    _value
                )
            )
        );
    }



    function GetSnap() public view returns (uint256) {
        return snapshot;
    }
    
}