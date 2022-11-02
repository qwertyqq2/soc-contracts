// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPlayer {

    function isAddr(address _playerAddr) external pure;

    function UpdatePos(uint256 _delta, uint256 _spos, uint256 _sneg, uint256 _nwin, uint256 _nloss, uint256 _p, uint256 _Spos) external;
    function UpdateNeg(uint256 _delta, uint256 _spos, uint256 _sneg, uint256 _nwin, uint256 _nloss, uint256 _p, uint256 _Sneg) external;

    function Get() external view returns(uint256);
}