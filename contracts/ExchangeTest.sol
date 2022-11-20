// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

contract ExchangeTest {
    address owner;
    address addr;
    mapping(address => uint256) balancesToken;

    constructor() {
        owner = msg.sender;
        addr = address(this);
    }

    function GetOwner() public view returns (address) {
        return owner;
    }

    function GetTokenBalance() public view returns (uint256) {
        return balancesToken[msg.sender];
    }

    function EthToToken() public payable {
        balancesToken[msg.sender] += msg.value;
    }

    function EthToTokenVirtual(uint _value) public pure returns(uint256){
        return _value;
    }

    function TokenToEth(uint256 val) public {
        require(addr.balance >= val, "Not enougt eth");
        require(msg.sender == owner, "Not a round");
        balancesToken[msg.sender] -= val;
        payable(msg.sender).transfer(val);
    }

    function TokenToEthVirtual(uint256 _value) public pure returns(uint256){
        return _value;
    }
}
