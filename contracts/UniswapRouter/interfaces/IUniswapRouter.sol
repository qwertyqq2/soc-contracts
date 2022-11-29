// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniV3Router{
    function swapWETHToDAI(uint amountIn) external returns(uint256 amountOut);

    function swapDAItoWETH(uint amountIn) external returns(uint256 amountOut);

    function Deposit() external payable;

    function withdraw(uint _amount) external;

    function curPriceWETHtoDAI(uint _amountIn) external returns(uint256);

    function curPriceDAItoWETH(uint _amountIn) external returns(uint256);

    function getBalanceEth() external view returns(uint256);

    function getBalanceDAI() external view returns(uint256);
}