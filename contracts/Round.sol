// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IGroup.sol";
import "./IExchangeTest.sol";
import "./ExchangeTest.sol";
import "./Lot.sol";
import "./ILot.sol";

import "hardhat/console.sol";

contract Round {
    address addr;

    mapping(address => uint256) players;
    address[] playersAddr;
    uint256 balance;
    uint256 timeCreation;
    address groupAddress;
    mapping(address => uint256) pendingPlayers;
    address[] pendingAddress;
    address exchangeAddress;
    uint256 deposit;

    address lotAddr;

    constructor(uint256 _deposit) {
        groupAddress = msg.sender;
        deposit = _deposit;
        addr = address(this);
        ExchangeTest exc = new ExchangeTest();
        exchangeAddress = address(exc);
    }

    event SendLotEvent(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    );

    event ReceiveLotEvent(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        uint256 delta
    );

    fallback() external payable {}

    receive() external payable {}

    modifier onlyGroup() {
        require(msg.sender == groupAddress, "It`s not a group contract!");
        _;
    }

    function Enter(address _sender, uint256 _value) public onlyGroup {
        require(_value >= deposit, "Not enouth deposit");
        pendingPlayers[_sender] += _value;
        balance += _value;
        pendingAddress.push(_sender);
    }

    modifier onlyOwner() {
        IGroup group = IGroup(groupAddress);
        address own = group.GetOwner();
        require(msg.sender == own, "You`re not owner group");
        _;
    }

    function StartRound() public onlyGroup {
        uint i=0;
        for (i = 0; i < pendingAddress.length; i++) {
            players[pendingAddress[i]] = pendingPlayers[pendingAddress[i]];
            pendingPlayers[pendingAddress[i]] = 0;
            playersAddr.push(pendingAddress[i]);
        }

        for (i = 0; i < pendingAddress.length; i++) {
            pendingAddress.pop();
        }

        timeCreation = block.timestamp;
    
   
        Lot lot = new Lot(1);
        lotAddr = address(lot);
    }

    function NewLot(
        address sender,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 price,
        uint256 val
    ) public onlyGroup {
        ILot lot = ILot(lotAddr);
        lot.New(timeFirst, timeSecond, sender, price, val);
    }

    function BuyLot(address sender, uint256 price) public onlyGroup {
        ILot lot = ILot(lotAddr);
        lot.Buy(sender, price);
    }

    function VerifyFull(
    address[] memory _owners, 
    uint256[] memory _prices,
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) public view {
        ILot lot = ILot(lotAddr);
        lot.VerifyFull(_owners, _prices, _timeFirst, _timeSecond, _value);
    }


    function VerifyPart(
        address[] memory _owners, 
        uint256[] memory _prices, 
        uint256 _snap
    ) public view{
        ILot lot = ILot(lotAddr);
        lot.VerifyPart(_owners, _prices, _snap);
    }


    function CorrectPart(
        address[] memory _owners, 
        uint256[] memory _prices, 
        uint256 _snap
    ) public{
        ILot lot = ILot(lotAddr);
        lot.CorrectPart(_owners, _prices, _snap);
    }
    
    function FinalLot(
        address[] memory senders,
        uint256[] memory prices,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value,
        uint256 countSend
    ) public {
        ILot lot = ILot(lotAddr);
        lot.EndLot(senders, prices, timeFirst, timeSecond, value, countSend);
    }

    function SendLot(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public onlyGroup {
        ILot lot = ILot(lotAddr);
        require(
            lot.PreSend(_sender, _price, _timeFirst, _timeSecond, _value),
            "Not verify lot!"
        );
        require(addr.balance >= _value, "Not enoungh eth on contract round!");
        IExchangeTest exchange = IExchangeTest(exchangeAddress);
        exchange.EthToToken{value: _value}();
        emit SendLotEvent(_sender, _price, _timeFirst, _timeSecond, _value);
    }

    function ReceiveLot(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public onlyGroup {
        ILot lot = ILot(lotAddr);
        require(
            lot.PreSend(_sender, _price, _timeFirst, _timeSecond, _value),
            "Not verify lot!"
        );

        IExchangeTest exchange = IExchangeTest(exchangeAddress);

        uint256 bal = addr.balance;
        exchange.TokenToEth(exchange.GetTokenBalance());
        uint256 delta = addr.balance - bal;

        emit ReceiveLotEvent(
            _sender,
            _price,
            _timeFirst,
            _timeSecond,
            _value,
            delta
        );
    }

    function GetSnap() public view returns (uint256) {
        ILot lot = ILot(lotAddr);
        return lot.GetSnap();
    }

    function GetBalance() public view returns (uint256) {
        return addr.balance;
    }
}
