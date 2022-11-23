// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "../UniswapRouter/UniswapRouter.sol";

contract Router{
    address uniRouter;

    constructor(address _uniRouter){
        uniRouter = _uniRouter;
    }
}