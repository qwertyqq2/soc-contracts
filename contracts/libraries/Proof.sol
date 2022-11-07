// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

library Proof {
    struct ProofRes{
                address addr;
                uint256 price;
                uint H1;
                uint H2;
                uint balance;
                uint prevSnap;
        }

    function NewProof(
        address _addr,
        uint256 _price,
        uint _H1,
        uint _H2,
        uint _balance
    ) external pure returns(ProofRes memory){
        ProofRes memory proof;
        proof.addr = _addr;
        proof.price = _price;
        proof.H1 = _H1;
        proof.H2 = _H2;
        proof.balance = _balance;
        return proof;
    }


    function snap(ProofRes calldata proof) internal pure returns(uint256) {
        return uint256(
                keccak256(
                    abi.encodePacked(uint256(uint160(proof.addr)), proof.balance)
                    )
                );
    }

    function GetProofBalance(ProofRes calldata proof) public pure returns(uint256){
        uint s = snap(proof);
        return uint256(keccak256(abi.encode(xor(xor(proof.H1, s), proof.H2))));
    } 


    function GetProofOwner(ProofRes calldata proof) external pure returns(uint256){
        return uint256(
            keccak256(
                abi.encodePacked(
                    proof.addr, 
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

    function NewProofEnoughPrice(address _prevOwner, uint _prevPrice, uint _prevSnap) external pure returns(ProofEnoungPrice memory){
        ProofEnoungPrice memory proof;
        proof.prevOwner = _prevOwner;
        proof.prevPrice = _prevPrice;
        proof.prevSnap = _prevSnap;
        return proof;
    }

    function GetProofEnoughPrice(ProofEnoungPrice calldata proof) external pure returns(uint256){
        return  uint256(keccak256(abi.encodePacked(proof.prevOwner, proof.prevPrice, proof.prevSnap)));
    }


    function xor(uint a, uint b) internal pure returns(uint256){
        return a^b;
    }


    
}