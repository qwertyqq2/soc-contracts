// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

interface IExchangeTest {
    function GetOwner() external view returns (address);

    function GetTokenBalance() external view returns (uint256);

    function EthToToken() external payable;

    function EthToTokenVirtual(uint _value) external pure returns(uint256);

    function TokenToEth(uint256 val) external payable;

    function TokenToEthVirtual(uint256 _value) external pure returns(uint256);
}
