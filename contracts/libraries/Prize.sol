// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "hardhat/console.sol";


library Prize {


    function Update(address _owner, uint _balance, uint _H, int _value) 
        external pure returns(uint256, uint256) {
        uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(_owner)),  uint(int(_balance)+_value))));
        uint val = xor(_H, snap);
        return (uint256(keccak256(abi.encode(val))), uint(int(_balance)+_value));
    }


    function SnapNew(address _owner, uint _balance, uint _price, uint _Hres)
        external pure returns(uint256){
            uint newBalance = _balance - _price;
            uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(_owner)),  newBalance)));
            return uint256(keccak256(abi.encode(xor(_Hres, snap))));
        }

    function SnapBuy(
        address _owner,
        address _prevOwner,
        uint _balance,
        uint _prevBalance,
        uint _price,
        uint _Hd
    ) external view returns(uint){
        uint newBalance = _balance - _price;
        uint newPrevBalance = _prevBalance + _price;
        uint snap = uint256(keccak256(abi.encodePacked(uint256(uint160(_owner)),  newBalance)));
        uint prevSnap = uint256(keccak256(abi.encodePacked(uint256(uint160(_prevOwner)),  newPrevBalance)));
        return uint256(keccak256(abi.encode(xor(_Hd, xor(snap, prevSnap)))));
    }

    function xor(uint a, uint b) internal pure returns(uint256){
        return a^b;
    }
}