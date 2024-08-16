//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DogToken} from "../src/DogToken.sol";
import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {

    bytes32 s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns(MerkleAirdrop, DogToken) {
        vm.startBroadcast();
        DogToken dogToken = new DogToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, dogToken);
        dogToken.mint(dogToken.owner(), s_amountToTransfer);
        dogToken.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, dogToken);

    }
}