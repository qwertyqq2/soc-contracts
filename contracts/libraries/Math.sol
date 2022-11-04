// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";


library Math {

    function xor(uint a, uint b) public pure returns (uint256){
        return a^b;
    }


    function GetSnap(address addr, uint balance) public pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(uint256(uint160(addr)), " ", balance)));
    }


}