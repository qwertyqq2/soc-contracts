// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

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
        uint _balance,
        uint256 _price,
        uint256 _Hres,
        uint256 _prevSnap
    ) external pure returns(bytes memory data){
        data = abi.encode(_balance ,_price, _Hres, _prevSnap);
    }

    function EncodeProofRes(
        uint _balance,
        uint256 _price,
        uint _Hres,
        uint _Hd,
        uint _prevSnap,
        address _prevOwner,
        uint _prevBalance
    ) external pure returns(bytes memory data){
        data = abi.encode(_balance ,_price, _Hres, _Hd, _prevSnap, _prevOwner, _prevBalance);
    }

    function EncodeProofRes(
        uint _balance,
        uint256 _price,
        uint256 _Hres
    ) external pure returns(bytes memory data){
        data = abi.encode(_balance ,_price, _Hres);
    }

    function EncodeProofRes(
        uint256 _balance,
        uint256 _price,
        uint _Hres,
        uint _Hd,
        uint256 _prevBalance
    ) external pure returns(bytes memory data){
        data = abi.encode(_balance ,_price, _Hres, _Hd, _prevBalance);
    }


        // uint _balance,
        // uint256 _price,
        // uint _Hres,
        // uint _Hd,
        // uint _prevSnap,
        // address _prevOwner,
        // uint _prevBalance
    function DecodeProofResBuyLot(bytes memory data)
        external pure returns(ProofRes memory proof){
            (proof.balance, proof.price, proof.Hres, proof.Hd, proof.prevOwner, proof.prevBalance) = 
                abi.decode(data, (uint, uint, uint, uint,  address, uint));
        }

    function DecodeProofResNewLot(bytes memory data)
        external pure returns(ProofRes memory proof){
            ( proof.balance, proof.price, proof.Hres) = 
                abi.decode(data, (uint, uint, uint));
        }

    function DecodeProofRes(bytes memory data)
        external pure returns(ProofRes memory proof){
            ( proof.balance, proof.price, proof.Hres,  proof.prevSnap) = 
                abi.decode(data, (uint, uint, uint, uint));
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

    function EncodeProofEnoungPrice(
        address _prevOwner,
        uint _prevPrice,
        uint _prevSnap
    ) external pure returns(bytes memory data){
        data = abi.encode(_prevOwner ,_prevPrice, _prevSnap);
    }


    function DecodeProofEP(bytes memory data)
            external pure returns(ProofEnoungPrice memory proofEP){
                ( proofEP.prevOwner, proofEP.prevPrice, proofEP.prevSnap) = 
                    abi.decode(data, (address, uint, uint));
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