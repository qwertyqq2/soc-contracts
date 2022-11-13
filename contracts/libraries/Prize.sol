// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "hardhat/console.sol";


library Prize {


    function Update(address _owner, uint _balance, uint _H1, uint _H2, int _value) 
        external pure returns(uint256, uint256) {
        uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(_owner)),  uint(int(_balance)+_value))));
        uint val = xor(xor(_H1, snap), _H2);
        return (uint256(keccak256(abi.encode(val))), uint(int(_balance)+_value));
    }


    function xor(uint a, uint b) internal pure returns(uint256){
        return a^b;
    }
}