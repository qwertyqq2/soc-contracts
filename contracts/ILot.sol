// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function EndLot(
        address[] memory senders,
        uint256[] memory prices,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 value,
        uint256 countSend
    ) external;

    function PreSend(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) external view returns (bool);

    function Join(
        address sender,
        uint256 rate,
        uint256 oldPrice
    ) external;

    function VerifyFull(
    address[] memory _owners,
    uint256[] memory _prices, 
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) external view ;

    function VerifyPart(
    address[] memory _owners,
    uint256[] memory _prices, 
    uint256 _snap
    ) external view;

    function CorrectPart(
    address[] memory _owners, 
    uint256[] memory _prices, 
    uint256 _snap
    ) external;

    function Return(uint256 _snap) external;

    function GetSnap() external view returns (uint256);
}
