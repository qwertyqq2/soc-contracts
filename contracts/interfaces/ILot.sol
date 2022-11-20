// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "../libraries/Proof.sol";
import "../libraries/Params.sol";


interface ILot {
    event NewLot(
        uint256 timeFirst,
        uint256 timeSecond,
        address owner,
        uint256 price,
        uint256 value
    );

    event BuyLot(address owner, uint256 price);

    function New(
        uint256 timeFirst,
        uint256 timeSecond,
        address owner,
        uint256 price,
        uint256 value
    ) external;

    function Buy(
        address sender, 
        uint256 newPrice,
        Proof.ProofEnoungPrice memory proof
        ) external;

    function End(
        Params.InitParams calldata init
    ) external;

    function Close(
        Params.InitParams calldata init,
        Proof.ProofRes calldata proof
    ) external; 


    function SetReceiveTokens(uint _receiveTokens) external;

    function GetReceiveTokens() external view returns(uint);

    function SetInitBalance(uint _initBal) external;

    function GetInitBalance() external view returns(uint);

    function Return(uint256 _snap) external;

    function GetSnap() external view returns (uint256);
}
