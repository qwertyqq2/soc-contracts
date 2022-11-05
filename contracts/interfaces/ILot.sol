// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/Proof.sol";


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

    function Buy(address sender, uint256 newPrice) external;


    function Join(
        address sender,
        uint256 rate
    ) external;

    function End(
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value
    ) external;

    function Close(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        Proof.ProofRes memory proof
    ) external;

    function SetReceiveTokens(uint _receiveTokens) external;

    function GetReceiveTokens() external view returns(uint);

    function verifyFull(
    address[] memory _owners,
    uint256[] memory _prices, 
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) external view ;

    function verifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes,
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

    function Return(uint256 _snap) external;

    function GetSnap() external view returns (uint256);
}
