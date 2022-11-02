// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGroup {
    function GetOwner() external view returns (address);

    function GetCurrentTime() external view returns (uint256);
}
