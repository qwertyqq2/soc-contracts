// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        Proof.ProofRes memory proof
    ) external;

    function JoinLot(
        Proof.ProofRes memory proof
    ) external;

    function GetPlayer(address player) external view returns (uint256);

    function FinalLot(
        address[] memory senders,
        uint256[] memory prices,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value,
        uint256 countSend
    ) external;

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
    ) external;

    function VerifyFull(
    address[] calldata _owners, 
    uint256[] calldata _prices,
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) external view; 

    function VerifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices, 
        address[] memory _support,
        uint256[] memory _additives,
        uint256[] memory _sizes,
        uint256 _snap
    ) external view;

    function CorrectOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes, 
        uint256 _snap
    ) external;

    function GetSnap() external view returns (uint256);

    function GetBalance() external view returns (uint256);

    function GetSnapshot() external view returns(uint256);

    function GetInitSnap() external view returns(uint256);

    function GetExchange() external view returns(address);
}
