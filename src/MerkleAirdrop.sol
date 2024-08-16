//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop{

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    //some list of addresses
    //allow someone in the list to claim a tokens
    address[] public claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping (address claimer=> bool claimed) private s_hasClaimed;

    event Claim(address account, uint256 amount);

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
        /*
        Checks
        */
       //checks if the account has already claimed the tokens
        if(s_hasClaimed[account]){
            revert  MerkleAirdrop__AlreadyClaimed();
        }
        //calculate using the account and the amount the hash _. leaf node 
        //hashes twice to prevent collisions
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        //uses leaf, merkle root, and merkle proof to verify the claim by calcuating and comparing the calulated and expected merkle root
        if(!MerkleProof.verify(merkleproof, i_merkleRoot, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        //mapping that will update a boolean value to true to indicate that the account has claimed the tokens
        s_hasClaimed[account] = true;
        //emission before the actual claiming process 
        /*
        Effects
        */
        emit Claim(account, amount);
        /*
        Interactions
        */
        i_airdropToken.safeTransfer(account, amount);
        
    }
}
