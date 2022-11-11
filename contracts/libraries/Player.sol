// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "hardhat/console.sol";


library Player {
    function UpdatePlus(address owner, uint balance, uint H1, uint H2) public pure returns(uint256){
        uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(owner)), " ", balance+1)));
        return xor(xor(H1, snap), H2);
    }

    function UpdateMinus(address owner, uint balance, uint H1, uint H2) public pure returns(uint256){
        uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(owner)), " ", balance-1)));
        return xor(xor(H1, snap), H2);
    }

    function xor(uint a, uint b) internal pure returns(uint256){
        return a^b;
    }
}