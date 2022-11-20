// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "hardhat/console.sol";

library Proof {
    struct ProofRes{
                address owner;
                uint256 price;
                uint Hres;
                uint Hd;
                uint balance;
                uint prevSnap;
                address prevOwner;
                uint prevBalance;
        }

    function NewProof(
        address _owner,
        uint256 _price,
        uint256 _Hres,
        uint256 _balance
    ) external pure returns(ProofRes memory){
        ProofRes memory proof;
        proof.owner = _owner;
        proof.price = _price;
        proof.Hres = _Hres;
        proof.balance = _balance;
        return proof;
    }


    function EncodeProofRes(
        uint256 _price,
        uint256 _Hres,
        uint256 _prevSnap
    ) external pure returns(bytes memory data){
        data = abi.encode( _price, _Hres, _prevSnap);
    }

    function DecodeProofRes(bytes memory data)
        external pure returns(ProofRes memory proof){
            ( proof.price, proof.Hres,  proof.prevSnap) = 
                abi.decode(data, (uint, uint, uint));
        }

    function snap(ProofRes calldata proof) internal pure returns(uint256) {
        return uint256(
                keccak256(
                    abi.encodePacked(uint256(uint160(proof.owner)), proof.balance)
                    )
                );
    }

    function GetProofBalance(ProofRes calldata proof) external pure returns(uint256){
        uint s = snap(proof);
        uint val = xor(proof.Hres, s);
        return uint256(keccak256(abi.encode(val)));
    } 


    function GetProofOwner(ProofRes calldata proof) external pure returns(uint256){
        return uint256(
            keccak256(
                abi.encodePacked(
                    proof.owner, 
                    proof.price, 
                    proof.prevSnap
                    )
                )
            );
    }

    struct ProofEnoungPrice{
        address prevOwner;
        uint prevPrice;
        uint prevSnap;
    }

    function NewProofEnoughPrice(address _prevOwner, uint _prevPrice, uint _prevSnap) 
        external pure returns(ProofEnoungPrice memory){
        ProofEnoungPrice memory proof;
        proof.prevOwner = _prevOwner;
        proof.prevPrice = _prevPrice;
        proof.prevSnap = _prevSnap;
        return proof;
    }

    function GetProofEnoughPrice(ProofEnoungPrice calldata proof) 
        external pure returns(uint256){
        return  uint256(
            keccak256(
                abi.encodePacked(
                    proof.prevOwner, 
                    proof.prevPrice, 
                    proof.prevSnap
                    )
                )
            );
    }

    function NewBalanceSnap(ProofRes calldata proof, uint _value) external pure returns(uint256){
        uint snapOwner = uint256(
                keccak256(
                    abi.encodePacked(uint256(uint160(proof.owner)), _value)
                    )
                );
        return uint256(
            keccak256(
                abi.encode(
                    xor(proof.Hres, snapOwner)
                )
            )
        );
    }


    function xor(uint a, uint b) internal pure returns(uint256){
        return a^b;
    }


    
}