// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "../libraries/Proof.sol";
import "../libraries/Params.sol";


interface IRound {
    function Enter(address _sender, uint256 _value) external;

    function StartRound() external;

    function CreateLot() external returns(address);

    function NewLot(
        address _lotAddr,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _val,
        Proof.ProofRes memory proof
    ) external;

    function BuyLot(
        address _lotAddr,
        Proof.ProofRes memory proof,
        Proof.ProofEnoungPrice memory proofEP 
    ) external;


    function GetPlayer(address player) external view returns (uint256);


    function SendLot(
        address _lotAddr,
        Params.InitParams memory initParams
    ) external;

    function ReceiveLot(
        address _lotAddr,
        Params.InitParams calldata _init,
        Proof.ProofRes calldata _proof,
        Params.PlayerParams calldata _params
    ) external returns(uint);



    function GetSnap() external view returns (uint256);

    function GetBalance() external view returns (uint256);

    function GetSnapshot() external view returns(uint256);

    function GetInitSnap() external view returns(uint256);

    function GetExchange() external view returns(address);

    function VerifyProofRes(
        Proof.ProofRes calldata proof
    ) external view returns(bool);

    function VerifyParamsPlayer(
        Params.PlayerParams calldata _params
    ) external view returns(bool);

    function GetParamsSnapshot() external view returns(uint);
}
