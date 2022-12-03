// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./Round.sol";
import "./interfaces/IRound.sol";

import "./libraries/Proof.sol";
import "./libraries/JumpSnap.sol";

contract Group {
    event CreateRoundEvent(address _roundAddress, uint256 _deposit);

    event EnterRoundEvent(address _roundAddress, address _sender);

    event StartRoundEvent(address _roundAddress, uint _bsnap, uint _psnap);

    event CreatedLotEvent(address _roundAddress, address _lotAddr);

    event NewLotEvent(
         address _roundAddress,
         address _lotAddr,
         address _owner,
         uint256 _timeFirst,
         uint256 _timeSecond,
         uint256 _price,
         uint256 _val,
         uint256 _lotSnap,
         uint256 _bsnap
     );


    event BuyLotEvent(
        address _roundAddress,
        address _lotAddr,
        address _sender,
        uint256 _price,
        uint256 _lotSnap,
        uint256 _bsnap
    );

    event SendLotEvent(
        address _roundAddress,
        address _lotAddr,
        uint256 _receiveTokens
    );

    event UpdatePlayerParams(
        address _roundAddress,
        address _owner,
        uint256 _nwin, 
        uint256 _n,
        uint256 _spos, 
        uint256 _sneg
    );


    event ReceiveLotEvent(
        address _roundAddress,
        address _lotAddr,
        address _owner,
        uint _balance,
        uint _SposDelta,
        uint _SnegDelta,
        uint _psnap,
        uint _bsnap
    );

    event WithdrawEvent(
        address _sender,
        uint _psnap,
        uint _bsnap
    );


    address owner;
    address roundAddr;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You`re not the owner");
        _;
    }

    function CreateRound(uint256 _deposit) public onlyOwner{
        Round round = new Round(_deposit);
        roundAddr = address(round);
        emit CreateRoundEvent(address(round), _deposit);
    }

    function Enter() public payable {
        IRound round = IRound(roundAddr);
        round.Enter(msg.sender, msg.value);
        payable(roundAddr).transfer(msg.value);
        emit EnterRoundEvent(roundAddr, msg.sender);
    }

    function StartRound() public {
        IRound round = IRound(roundAddr);
        uint bsnap;
        uint psnap;
        (bsnap, psnap) = round.StartRound();
        emit StartRoundEvent(roundAddr, bsnap, psnap);
    }

    function CreateLot() external{
        IRound round = IRound(roundAddr);
        address lotAddr = round.CreateLot();
        emit CreatedLotEvent(roundAddr, lotAddr);
    }

    modifier onlyPlayer() {
        IRound round = IRound(roundAddr);
        require(round.GetPlayer(msg.sender) > 0, "You're not a player");
        _;
    }

    function NewLot(
        address _lotAddr,
        bytes memory initParamsData,
        bytes memory proofResData
    ) external {
        Proof.ProofRes memory proof = Proof.DecodeProofResNewLot(proofResData);
        proof.owner = msg.sender;
        Params.InitParams memory initParams = Params.DecodeInitParams(initParamsData);
        IRound round = IRound(roundAddr);
        uint lotSnap;
        uint balancesSnap;
        (lotSnap, balancesSnap) = round.NewLot(_lotAddr, initParams, proof);
         emit NewLotEvent(
             roundAddr,
             _lotAddr,
             msg.sender,
             initParams.timeFirst,
             initParams.timeSecond,
             proof.price,
             initParams.value,
             lotSnap,
             balancesSnap
     );
     console.log("New lot!");
    }

    function BuyLot(
        address _lotAddr,
        bytes memory proofResData,
        bytes memory proofEPData 
        ) external {
        Proof.ProofRes memory proofRes = Proof.DecodeProofResBuyLot(proofResData);
        proofRes.owner = msg.sender;
        Proof.ProofEnoungPrice memory proofEP = Proof.DecodeProofEP(proofEPData);
        IRound round = IRound(roundAddr);
        uint lotSnap;
        uint balancesSnap;
        (lotSnap, balancesSnap) = round.BuyLot(_lotAddr, proofRes, proofEP);
        emit BuyLotEvent(
            roundAddr,
            _lotAddr,
            msg.sender,
            proofRes.price,
            lotSnap,
            balancesSnap
        );
        console.log("Buy lot!");
    }


    function SendLot(
        address _lotAddr,
        bytes memory initParamsData
    ) external{
        Params.InitParams memory initParams = Params.DecodeInitParams(initParamsData);
        IRound round = IRound(roundAddr);
        uint amountOut = round.SendLot(_lotAddr, initParams);
        emit SendLotEvent(roundAddr, _lotAddr, amountOut);
        console.log("Send lot!");
    }

    function ReceiveLot(
        address _lotAddr,
        address _owner,
        bytes memory initParamsData,
        bytes memory proofResData,
        bytes memory playerParamsData
    ) external{
        Params.InitParams memory initParams = Params.DecodeInitParams(initParamsData);
        Proof.ProofRes memory proof = Proof.DecodeProofRes(proofResData);
        proof.owner = _owner;
        Params.PlayerParams memory params = Params.DecodePlayerParams(playerParamsData);
        IRound round = IRound(roundAddr);
        bytes memory newParamsData;
        uint newBalance;
        (newParamsData, newBalance) = round.ReceiveLot(_lotAddr, initParams, proof, params);
        Params.PlayerParams memory NewParams = Params.DecodePlayerParamsInTuple(newParamsData);
        emit UpdatePlayerParams(
            roundAddr, 
            NewParams.owner, 
            NewParams.nwin,
            NewParams.n,
            NewParams.spos,
            NewParams.sneg);
        uint bsnap = round.GetBalancesSnap();
        uint psnap = round.GetParamsSnap();
        emit ReceiveLotEvent(
            roundAddr,
            _lotAddr,
            _owner,
            newBalance,
            NewParams.spos - params.spos,
            NewParams.sneg - params.sneg,
            psnap,
            bsnap
        );
        console.log("Receive lot!");
    }


    function Withdraw(
        bytes memory proofResData,
        bytes memory playerParamsData
    ) external {
        Proof.ProofRes memory proof = Proof.DecodeProofRes(proofResData);
        proof.owner = msg.sender;
        Params.PlayerParams memory params = Params.DecodePlayerParams(playerParamsData);
        IRound round = IRound(roundAddr);
        (uint psnap, uint bsnap) = round.Withdraw(params, proof);
        emit WithdrawEvent(msg.sender, psnap, bsnap);
    }


    function EncodeEP(address _prevOwner, uint _prevPrice, uint _prevSnap) external view{
        bytes memory data = Proof.EncodeProofEnoungPrice(_prevOwner, _prevPrice, _prevSnap);
        console.logBytes(data);
        Proof.ProofEnoungPrice memory proofEP = Proof.DecodeProofEP(data);
        console.log(proofEP.prevOwner);
        console.log(proofEP.prevPrice);
        console.log(proofEP.prevSnap);
    }
}  
