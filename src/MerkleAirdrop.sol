//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    //some list of addresses
    //allow someone in the list to claim a tokens

    address[] private claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address claimer => bool claimed) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claim(address account, uint256 amount);

    //going to use merkle proofs
    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    //claim function to allow users to claim tokens
    /**
     *
     * @param account this parameter is the address of the account that will claim the tokens
     * @param amount this parameter is the amount of tokens that the account will claim
     * @param merkleproof this parameter is the merkle proof that will be used to verify the claim
     * @param v this parameter is the v value of the signature
     * @param r this parameter is the r value of the signature
     * @param s this parameter is the s value of the signature
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleproof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        /*
        Checks
        */
        //checks if the account has already claimed the tokens
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        //calculate using the account and the amount the hash _. leaf node
        //hashes twice to prevent collisions
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        //uses leaf, merkle root, and merkle proof to verify the claim by calcuating and comparing the calulated and expected merkle root
        if (!MerkleProof.verify(merkleproof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        //check the signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    //Getter functions
    /*
     address[] private claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping (address claimer=> bool claimed) private s_hasClaimed;
     */
    function getClaimers() external view returns (address[] memory) {
        return claimers;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function getHasClaimed(address claimer) external view returns (bool) {
        return s_hasClaimed[claimer];
    }
}
