// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "../libraries/Proof.sol";
import "../libraries/Params.sol";


interface IRound {
    function Enter(address _sender, uint256 _value) external;

    function StartRound() external returns(uint, uint, uint, uint);

    function CreateLot() external returns(address);

    function NewLot(
        address _lotAddr,
        Params.InitParams memory initParams,
        Proof.ProofRes memory proof
    ) external returns(uint, uint);

    function BuyLot(
        address _lotAddr,
        Proof.ProofRes memory proof,
        Proof.ProofEnoungPrice memory proofEP 
    ) external returns(uint, uint);


    function GetPlayer(address player) external view returns (uint256);


    function SendLot(
        address _lotAddr,
        Params.InitParams memory initParams
    ) external returns(uint amountOut, uint reserve);


    function ReceiveLot(
        address _lotAddr,
        Params.InitParams calldata _init,
        Proof.ProofRes calldata _proof,
        Params.PlayerParams calldata _params
    ) external returns( bytes memory, uint);

    function Withdraw(
        Params.PlayerParams calldata _params,
        Proof.ProofRes calldata _proof
        ) external returns(uint, uint);

    function GetReserve() external view returns(uint);

    function GetSnap() external view returns (uint256);

    function GetBalance() external view returns (uint256);

    function GetSnapshot() external view returns(uint256);

    function GetInitSnap() external view returns(uint256);

    function GetParamsSnap() external view returns(uint);

    function GetBalancesSnap() external view returns(uint);

    function EnoughRes(Proof.ProofRes calldata proof)external view returns(bool, uint, uint);

    function CorrectEp(
        address _lotAddr, 
        uint _newPrice,
        Proof.ProofEnoungPrice calldata _proofEP
        ) external view returns(bool, uint, uint);

}
