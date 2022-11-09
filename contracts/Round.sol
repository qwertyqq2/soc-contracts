// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGroup.sol";
import "./interfaces/IExchangeTest.sol";
import "./interfaces/ILot.sol";
import "./interfaces/IRound.sol";


import "./libraries/Proof.sol";
import "./libraries/Math.sol";
import "./libraries/Player.sol";


import "./ExchangeTest.sol";
import "./Lot.sol";

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

    uint256 balancesSnap = 115792089237316195423570985008687907853269984665640564039457584007913129639935;


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
            balancesSnap = Math.xor(balancesSnap, uint256(
                                                    keccak256(abi.encodePacked(
                                                        uint256(uint160(pendingAddress[i])), 
                                                        deposit
                                                        )))
                                        );
        }

        balancesSnap = uint256(keccak256(abi.encode(balancesSnap)));
        timeCreation = block.timestamp;

   
        Lot lot = new Lot(1);
        lotAddr = address(lot);

    }


    
    modifier enoughRes(Proof.ProofRes calldata proof){
        uint res = Proof.GetProofBalance(proof);
        require(res == balancesSnap, "Not proof");
        require(proof.price<=proof.balance, "Not enoung res");
        _;
    }

    function NewLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes calldata proof
    ) public onlyGroup enoughRes(proof) {
        ILot lot = ILot(lotAddr);
        lot.New(_timeFirst, _timeSecond, proof.addr, proof.price, _val);
    }

    function BuyLot(
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP 
     ) public onlyGroup enoughRes(proofRes) {
        ILot lot = ILot(lotAddr);
        lot.Buy(proofRes.addr, proofRes.price, proofEP);
    }

    

    function SendLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(lotAddr);
        lot.End(_timeFirst, _timeSecond, _value);
        uint initBal = exc.GetTokenBalance();
        exc.EthToToken{value: _value}();
        lot.SetReceiveTokens(exc.GetTokenBalance() - initBal);
        console.log("Lot sent ");
    }


    function ReceiveLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes calldata proof
    )  public onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(lotAddr);
        lot.Close(_timeFirst, _timeSecond, _value, proof);
        uint initBal = address(this).balance;
        uint val = exc.GetTokenBalance();
        exc.TokenToEth(val);
        uint res = address(this).balance - initBal;
        console.log("Lot received");

    }


    function CancelLot(
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP
    ) external enoughRes(proofRes){
        ILot lot = ILot(lotAddr);
        lot.Cancel(proofRes.addr, proofEP.prevPrice, proofEP);
        console.log("Lot is canceled");
    }

    function SendCanceled(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(lotAddr);
        lot.EndCancel(_timeFirst, _timeSecond, _value, _sender);
        uint count = exc.EthToTokenVirtual(_value);
        lot.SetReceiveTokens(count);
        console.log("Canceled send");
    }

    function ReceiveCanceled(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(lotAddr);
        lot.CloseCancel(_timeFirst, _timeSecond, _value, _sender);
        uint count = lot.GetReceiveTokens();
        uint res = exc.TokenToEthVirtual(count);
        if(res<0){
            console.log("it was in vain");
        }
        else{
            console.log("You`re right");
        }
    }

    function setBalance(Proof.ProofRes calldata proof, uint _value) internal {
        balancesSnap = Proof.NewBalanceSnap(proof, _value);
    }

    function GetSnap() public view returns (uint256) {
        ILot lot = ILot(lotAddr);
        return lot.GetSnap();
    }

    function GetBalance() public view returns (uint256) {
        return addr.balance;
    }
    
    function GetSnapshot() public view returns(uint256){
        return balancesSnap;
    }

    function GetInitSnap() public pure returns(uint256){
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }

    function GetExchange() public view returns(address){
        return exchangeAddress;
    }



    
}
