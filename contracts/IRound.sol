// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRound {
    function Enter(address _sender, uint256 _value) external;

    function StartRound() external;

    function NewLot(
        address sender,
        uint256 timeFirst,
        uint256 timeSecond,
        uint256 price,
        uint256 val
    ) external;

    function BuyLot(address sender, uint256 price) external;

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
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) external;

    function ReceiveLot(
        address _sender,
        uint256 _price,
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value
    ) external;

    function GetSnap() external view returns (uint256);

    function GetBalance() external view returns (uint256);
}
