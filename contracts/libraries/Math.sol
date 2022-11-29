// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

library Math {

    function xor(uint a, uint b) public pure returns (uint256){
        return a^b;
    }


    function GetSnap(address addr, uint balance) external pure returns(uint256){
        return uint256(
                keccak256(
                    abi.encodePacked(
                        uint256(uint160(addr)), 
                        balance
                        )
                    )
                );
    }

    function GetInitSnap(
        uint _timeFirst, 
        uint _timeSecond, 
        address _owner, 
        uint _price,
        uint _value
        ) external pure returns(uint256){
        return uint256(
            keccak256(
                abi.encodePacked(
                    _timeFirst,
                    _timeSecond, 
                    _owner, 
                    _price, 
                    _value
                )
            )
        );
    }

    function GetNewBuySnapshot(
        address _sender,
        uint _newPrice,
        uint _snap
    ) external pure returns(uint256){
        return uint256(
                keccak256(
                    abi.encodePacked(
                        _sender, 
                        _newPrice,
                        _snap
                    )
                )
        );
    }

    function KeccakOne(uint snap) public pure returns(uint256){
        return uint256(keccak256(abi.encode(snap)));
    }

    function Abs(int x) public  pure returns (int) {
        return x >= 0 ? x : -x;
    }


}