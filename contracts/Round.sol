// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./interfaces/IGroup.sol";
import "./interfaces/IExchangeTest.sol";
import "./interfaces/ILot.sol";
import "./interfaces/IRound.sol";


import "./libraries/Proof.sol";
import "./libraries/Math.sol";
import "./libraries/Prize.sol";


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
    }

    function CreateLot() external onlyGroup returns(address){
        require(timeCreation!=0);
        Lot lot  = new Lot();
        lotAddr = address(lot);
        return lotAddr;
    }

    
    modifier enoughRes(Proof.ProofRes calldata proof){
        uint res = Proof.GetProofBalance(proof);
        require(res == balancesSnap, "Not proof");
        require(proof.price<=proof.balance, "Not enoung res");
        _;
    }

    function NewLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes calldata proof
    ) public onlyGroup enoughRes(proof) {
        balancesSnap = Prize.SnapNew(proof.owner, proof.balance, proof.price, proof.Hres);
        ILot lot = ILot(_lotAddr);
        lot.New(_timeFirst, _timeSecond, proof.owner, proof.price, _val);
    }

    function BuyLot(
        address _lotAddr,
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP 
     ) public onlyGroup enoughRes(proofRes) {
        balancesSnap = Prize.SnapBuy(
            proofRes.owner,
            proofRes.prevOwner,
            proofRes.balance,
            proofRes.prevBalance,
            proofRes.price,
            proofRes.Hd
        );
        ILot lot = ILot(_lotAddr);
        lot.Buy(proofRes.owner, proofRes.price, proofEP);
    }

    

    function SendLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) public onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
        lot.End(_timeFirst, _timeSecond, _value);
        uint initBal = exc.GetTokenBalance();
        exc.EthToToken{value: _value}();
        lot.SetReceiveTokens(exc.GetTokenBalance() - initBal);
        console.log("Lot sent ");
    }


    function ReceiveLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes calldata proof
    )  public onlyGroup returns(uint newBalance){
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
        lot.Close(_timeFirst, _timeSecond, _value, proof);
        uint initBal = address(this).balance;
        uint val = exc.GetTokenBalance();
        exc.TokenToEth(val);
        int res = int(address(this).balance) - int(initBal) - int(_value);
        if(res>=0) (balancesSnap, newBalance)  = Prize.Update(
                                                    proof.owner,
                                                    proof.balance, 
                                                    proof.Hres,
                                                    int(proof.price)
                                                    );
        else (balancesSnap, newBalance) = Prize.Update(
                                                    proof.owner, 
                                                    proof.balance,
                                                    proof.Hres,
                                                    -int(proof.price)
                                                    );
        console.log("Lot received");
    }


    function CancelLot(
        address _lotAddr,
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP
    ) external enoughRes(proofRes){
        ILot lot = ILot(_lotAddr);
        lot.Cancel(proofRes.owner, proofEP.prevPrice, proofEP);
        console.log("Cancel lot: ", proofRes.owner);
    }

    function SendCanceled(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
        lot.EndCancel(_timeFirst, _timeSecond, _value, _sender);
        uint count = exc.EthToTokenVirtual(_value);
        lot.SetReceiveTokens(count);
    }

    function ReceiveCanceled(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external onlyGroup{
        IExchangeTest exc = IExchangeTest(exchangeAddress);
        ILot lot = ILot(_lotAddr);
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

    function VerifyProofRes(
        Proof.ProofRes calldata proof
    ) external view returns(bool){
        uint snap = Proof.GetProofBalance(proof);
        return snap==balancesSnap;
    }

    
}
