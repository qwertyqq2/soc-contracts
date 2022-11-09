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

    function Buy(
        address sender, 
        uint256 newPrice,
        Proof.ProofEnoungPrice memory proof
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

    function Cancel(
        address _sender,
        uint _price,
        Proof.ProofEnoungPrice calldata proof
    ) external;


    function EndCancel(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
        ) external;


    function CloseCancel(
        uint256 _timeFirst,
        uint256 _timeSecond,
        uint256 _value,
        address _sender
    ) external;

    function SetReceiveTokens(uint _receiveTokens) external;

    function GetReceiveTokens() external view returns(uint);

    function Return(uint256 _snap) external;

    function GetSnap() external view returns (uint256);
}
