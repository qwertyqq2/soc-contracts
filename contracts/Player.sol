// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract Player {
    uint balance;
    address roundAddress;
    address owner;

    uint H1;
    uint H2;

    constructor(uint init, address _owner) {
        balance = init;
        owner = _owner;
        roundAddress = msg.sender;
    }

    

}
