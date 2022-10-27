// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExchangeTest {
    function GetOwner() external view returns (address);

    function GetTokenBalance() external view returns (uint256);

    function EthToToken() external payable;

    function TokenToEth(uint256 val) external payable;
}
