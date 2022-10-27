// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract Player {
    
    address playerAddr;
    address roundAddr;

    /*
    params = (spos, sneg, nwin, nloss, p)
    */

    uint256 snapParam;


    uint256 weight;

    constructor(address _playerAddr, address _roundAddress, uint256 _initWeight){
        playerAddr = _playerAddr;
        roundAddr = _roundAddress;
        snapParam = uint256(
            keccak256(abi.encodePacked(_initWeight))
        );
        weight = _initWeight;
    }

    function isAddr(address _playerAddr) public view{
        require(playerAddr == _playerAddr, "Not right addr");
    }


    function proofParams(uint256 _spos, uint256 _sneg, uint256 _nwin, uint256 _nloss, uint256 _p) private view{
        uint256 _snap =  uint256(
            keccak256(abi.encodePacked(_spos, _sneg, _nwin, _nloss, _p))
        );
        require(_snap == snapParam, " Not right param");
    }


    function UpdatePos(uint256 _delta, uint256 _spos, uint256 _sneg, uint256 _nwin, uint256 _nloss, uint256 _p, uint256 _Spos) public{
        proofParams(_spos, _sneg, _nwin, _nloss, _p);

        uint256 newWeight = _p + (10000 - _p)*(_spos+_delta)/(_Spos+_delta);

        snapParam = uint256(
            keccak256(abi.encodePacked(_spos+_delta, _sneg, _nwin+1, _nloss, newWeight))
        );

        weight = newWeight;
    }


    function UpdateNeg(uint256 _delta, uint256 _spos, uint256 _sneg, uint256 _nwin, uint256 _nloss, uint256 _p, uint256 _Sneg) public{
        proofParams(_spos, _sneg, _nwin, _nloss, _p);

        uint256 K = (_nloss+1)*100/(2*(_nwin+_nloss+1)) + (100 - (_sneg-_delta)/(_Sneg-_delta)*100)/2;

        uint256 newWeight = _p*(10000 - _delta)*K/100;

        snapParam = uint256(
            keccak256(abi.encodePacked(_spos, _sneg-_delta, _nwin, _nloss+1, newWeight))
        );
    }

    function Get() public view returns(uint256){
        return weight;
    }

}
