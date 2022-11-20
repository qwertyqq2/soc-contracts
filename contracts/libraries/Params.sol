// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "hardhat/console.sol";


library Params {
    struct PlayerParams{
        address owner; 
        uint balance;
        uint nwin;
        uint n;
        uint spos;
        uint sneg;
        uint Hp;
    }

    function NewPlayerParams(
        address _owner, 
        uint _balance
    ) external pure returns(PlayerParams memory){
        PlayerParams memory params;
        params.owner = _owner;
        params.balance = _balance;
        params.nwin = 0;
        params.n = 0;
        params.spos = 0;
        params.sneg = 0;
        return params;
    }

    function GetPlayerParams(
        address _owner,
        uint _balance,
        uint _nwin,
        uint _n,
        uint _spos,
        uint _sneg
    ) external pure returns(PlayerParams memory){
        PlayerParams memory params;
        params.owner = _owner;
        params.balance = _balance;
        params.nwin = _nwin;
        params.n = _n;
        params.spos = _spos;
        params.sneg = _sneg;
        return params;
    }

    function EncodePlayerParams(
        address _owner,
        uint _balance,
        uint _nwin,
        uint _n,
        uint _spos,
        uint _sneg,
        uint _Hp
    ) external pure returns(bytes memory data){
        data = abi.encode( _owner, _balance, _nwin, _n, _spos, _sneg, _Hp);
    }


    function DecodePlayerParams(bytes memory data) 
        external pure returns(PlayerParams memory){
            PlayerParams memory params;
            (params.owner, params.balance, params.nwin, params.n, params.spos, params.sneg, params.Hp) 
                = abi.decode(data,
                ( address, uint, uint, uint, uint, uint, uint));
            return params;
        }


    function GetSnapParamPlayer(PlayerParams calldata params) 
        public pure returns(uint){
            return uint(
                keccak256(
                    abi.encodePacked(
                        params.owner, 
                        params.balance, 
                        params.nwin,
                        params.n, 
                        params.spos, 
                        params.sneg
                        )));
        }


    function GetSnapParamPlayerOut(
        address _owner, 
        uint _balance,
        uint _nwin,
        uint _n,
        uint _spos,
        uint _sneg
    ) external pure returns(uint){
            return uint(
                keccak256(
                    abi.encodePacked(
                        _owner, 
                        _balance, 
                        _nwin,
                        _n, 
                        _spos, 
                        _sneg
                        )));
        }


    struct InitParams{
        uint timeFirst;
        uint timeSecond;
        uint value;
    }


    function NewInit(uint _timeF, uint _timeS, uint _val) 
        external pure returns(InitParams memory){
            InitParams memory init;
            init.timeFirst = _timeF;
            init.timeSecond = _timeS;
            init.value = _val;
            return init;
        }

    function EncodeInitParams(
        uint _timeF,
        uint _timeS,
        uint _val
    ) external pure returns(bytes memory){
        return abi.encode(_timeF, _timeS, _val);
    }

    function DecodeInitParams(bytes memory data) 
        external pure returns(InitParams memory init){
            (init.timeFirst, init.timeSecond, init.value) = abi.decode(data, (uint, uint, uint));
    } 

}
