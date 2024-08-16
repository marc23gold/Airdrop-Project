//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdrop {
    //some list of addresses
    //allow someone in the list to claim a tokens
    address[] public claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    //going to use merkle proofs
    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }
}