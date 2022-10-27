// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Round.sol";
import "./IRound.sol";

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
        uint256 _val
    ) public {
        IRound round = IRound(roundAddr);
        round.NewLot(msg.sender, _timeFirst, _timeSecond, _price, _val);
    }

    function BuyLot(uint256 newPrice) public {
        IRound round = IRound(roundAddr);
        round.BuyLot(msg.sender, newPrice);
    }

    function GetCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function FinalLot(
        address[] memory senders,
        uint256[] memory prices,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value,
        uint256 countSend
    ) public {
        IRound round = IRound(roundAddr);
        round.FinalLot(
            senders,
            prices,
            timeFirst,
            timeSecond,
            value,
            countSend
        );
    }

    function SendLot(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public {
        IRound round = IRound(roundAddr);
        round.SendLot(_sender, _price, _timeFirst, _timeSecond, _value);
    }

    function ReceiveLot(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public {
        IRound round = IRound(roundAddr);
        round.ReceiveLot(_sender, _price, _timeFirst, _timeSecond, _value);
    }

    function GetSnap() public view returns (uint256) {
        IRound round = IRound(roundAddr);
        return round.GetSnap();
    }

    function GetBalRound() public view returns (uint256) {
        IRound round = IRound(roundAddr);
        return round.GetBalance();
    }

    function GetRound() public view returns(address){
        return roundAddr;
    }
}
