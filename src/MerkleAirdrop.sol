//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop{
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

    //claim function to allow users to claim tokens
    /**
     *
     * @param account this parameter is the address of the account that will claim the tokens
     * @param amount this parameter is the amount of tokens that the account will claim
     * @param merkleproof this parameter is the merkle proof that will be used to verify the claim
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleproof) external {
        //calculate using the account and the amount the hash _. leaf node 
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
    }
}
