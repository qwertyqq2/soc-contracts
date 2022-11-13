// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "../libraries/Proof.sol";

interface IRound {
    function Enter(address _sender, uint256 _value) external;

    function StartRound() external;

    function NewLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes memory proof
    ) external;

    function BuyLot(
        Proof.ProofRes memory proof,
        Proof.ProofEnoungPrice memory proofEP 
    ) external;

    function JoinLot(
        Proof.ProofRes memory proof
    ) external;

    function GetPlayer(address player) external view returns (uint256);


    function SendLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) external;

    function ReceiveLot(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes memory proof
    ) external returns(uint);

   
    function CancelLot(
        Proof.ProofRes calldata proofRes, 
        Proof.ProofEnoungPrice calldata proofEP
    ) external;


    function SendCanceled(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external;


    function ReceiveCanceled(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external;

    function GetSnap() external view returns (uint256);

    function GetBalance() external view returns (uint256);

    function GetSnapshot() external view returns(uint256);

    function GetInitSnap() external view returns(uint256);

    function GetExchange() external view returns(address);

    function VerifyProofRes(
        Proof.ProofRes calldata proof
    ) external view returns(bool);
}
