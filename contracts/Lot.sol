// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRound.sol";
import "./IPlayer.sol";
import "hardhat/console.sol";


contract Lot {
    address roundAddr;
    uint256 numberLot;

    uint256 snapshot;
    uint256 snapshot1;

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

    function getProof(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public pure returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _sender,
                        _price,
                        _timeFirst,
                        _timeSecond,
                        _value
                    )
                )
            );
    }

    function proof(
        address[] memory _senders,
        uint256[] memory _prices,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        uint256 _snapshot
    ) private pure returns (bool) {
        uint256 snap = uint256(
            keccak256(
                abi.encodePacked(
                    _timeFirst,
                    _timeSecond,
                    _senders[0],
                    _prices[0],
                    _value
                )
            )
        );
        uint48 i = 1;
        for (; i < _senders.length; i++) {
            address send = _senders[i];
            uint256 price = _prices[i];
            snap = uint256(keccak256(abi.encodePacked(send, price, snap)));
        }
        if (snap == _snapshot) {
            return true;
        } else {
            return false;
        }
    }


    function New(
        uint256 timeFirst,
        uint256 timeSecond,
        address owner,
        uint256 price,
        uint256 value
    ) public onlyRound {
        snapshot = uint256(
            keccak256(
                abi.encodePacked(timeFirst, timeSecond, owner, price, value)
            )
        );
        console.log("New lot owner: ", owner, " new lot price: ", price);
    }


    function Buy(address sender, uint256 newPrice) public onlyRound {
        require(exist == true, "Already not exist");
        snapshot = uint256(
            keccak256(abi.encodePacked(sender, newPrice, snapshot))
        );
        if (newPrice <= 0) {
            exist = false;
        }
        console.log("New lot owner: ", sender, " new lot price: ", newPrice);
    }


    function Verify(address[] memory _senders, uint256[] memory _prices, uint256 _snapPoint, address _playerAddr) public 
        view onlyRound returns(uint, bool){
        
        require(exist == true, "Already not exist");

        for(uint i=0;i<_senders.length;i++){
            _snapPoint = uint256(
            keccak256(abi.encodePacked(_senders[i], _prices[i], _snapPoint))
        );
        }
        require(_snapPoint == snapshot, "Not right verify");

        IPlayer player = IPlayer(_playerAddr);

        uint256 oldPrice = _prices[0];
        uint256 Reserve = roundAddr.balance;
        uint256 w = player.Get();

        if(oldPrice>w*Reserve/10000){
            return (101, false);
        }

        uint256 newPrice = _prices[1];

        if(newPrice>w*Reserve/10000){
            return (102, false);
        }

        return (0, true);
    }

    function Return(uint256 _snap) public{
        snapshot = _snap;
    }

    function IsOwner(address sender, uint16 price) public view returns (bool) {
        uint256 snap = uint256(
            keccak256(abi.encodePacked(sender, price, snapshot1))
        );
        if (snap == snapshot) {
            return true;
        } else {
            return false;
        }
    }

    function EndLot(
        address[] memory _senders,
        uint256[] memory _prices,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        uint256 _countSend
    ) public onlyRound {
        require(
            proof(_senders, _prices, _timeFirst, _timeSecond, _value, snapshot),
            "Not right!"
        );
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


    function PreSend(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public view onlyRound returns (bool) {
        require(
            getProof(_sender, _price, _timeFirst, _timeSecond, _value) ==
                snapshot1,
            "Not right data!"
        );
        return true;
    }


    function Join(address sender, uint256 rate) public {
        require(exist, "Already not exist");
        require(rate > 0, "Not ehoung rate!");
        snapshot = uint256(
            keccak256(abi.encodePacked(sender, rate, snapshot, uint8(1)))
        );
        emit JoinLot(sender, rate, snapshot);
    }

    function GetSnap() public view returns (uint256) {
        return snapshot;
    }
}