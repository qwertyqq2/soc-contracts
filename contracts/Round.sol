// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGroup.sol";
import "./interfaces/IExchangeTest.sol";
import "./interfaces/ILot.sol";

import "./libraries/Proof.sol";
import "./libraries/Math.sol";


import "./ExchangeTest.sol";
import "./Lot.sol";
import "./Player.sol";

import "hardhat/console.sol";

contract Round {
    address addr;

    mapping(address => uint256) players;
    uint256 balance;
    uint256 timeCreation;
    address groupAddress;
    mapping(address => uint256) pendingPlayers;
    address[] pendingAddress;
    address exchangeAddress;
    uint256 deposit;

    address lotAddr;

    uint256 snapshot = 115792089237316195423570985008687907853269984665640564039457584007913129639935;


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
        uint8 i=0;
        for (i = 0; i < pendingAddress.length; i++) {
            pendingPlayers[pendingAddress[i]] = 0;
            snapshot = Math.xor(snapshot, uint256(keccak256(abi.encodePacked(
                uint256(uint160(pendingAddress[i])), " ", deposit))));
        }
        timeCreation = block.timestamp;

   
        Lot lot = new Lot(1);
        lotAddr = address(lot);
    }


    
    modifier enoughRes(Proof.ProofRes memory proof){
        uint res = Proof.GetProof(proof);
        require(res == snapshot, "Not proof");
        require(proof.price<=proof.balance, "Not enoung res");
        _;
    }

    function NewLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes memory proof
    ) public onlyGroup enoughRes(proof) {
        ILot lot = ILot(lotAddr);
        lot.New(_timeFirst, _timeSecond, proof.addr, proof.price, _val);
    }

    function BuyLot(
        Proof.ProofRes memory proof
     ) public onlyGroup enoughRes(proof) {
        ILot lot = ILot(lotAddr);
        lot.Buy(proof.addr, proof.price);
    }

    function JoinLot(
        Proof.ProofRes memory proof
    ) public onlyGroup enoughRes(proof) {
        ILot lot = ILot(lotAddr);
        lot.Join(proof.addr, proof.price);
    }

    function VerifyFull(
    address[] calldata _owners, 
    uint256[] calldata _prices,
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) public view {
        ILot lot = ILot(lotAddr);
        lot.verifyFull(_owners, _prices, _timeFirst, _timeSecond, _value);
    }


    function VerifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices, 
        address[] memory _support,
        uint256[] memory _additives,
        uint256[] memory _sizes,
        uint256 _snap
    ) public view{
        ILot lot = ILot(lotAddr);
        lot.verifyOwner(_owners, _prices, _support, _additives, _sizes, _snap);
    }


    function CorrectOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes, 
        uint256 _snap
    ) public{
        ILot lot = ILot(lotAddr);
        lot.CorrectOwner(_owners, _prices, _support, _additives, _sizes, _snap);
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
    
    function GetSnapshot() public view returns(uint256){
        return snapshot;
    }

    function GetInitSnap() public pure returns(uint256){
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }
}
