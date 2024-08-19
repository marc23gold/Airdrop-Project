//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DogToken} from "../src/DogToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";


contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    //init variables for contracts passed in and pranks
    MerkleAirdrop public merkleAirdrop;
    DogToken public dogToken;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 userPrivKey;
    uint256 amountToCollect = (25 * 1e18); // 25.000000
    uint256 amountToSend = amountToCollect * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            //deploy with the script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, dogToken) = deployer.deployMerkleAirdrop();
        } else {
            //deploy the contract
            //pass in the merkle root and the airdrop token
            dogToken = new DogToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, dogToken);
            dogToken.mint(dogToken.owner(), amountToSend);
            dogToken.transfer(address(merkleAirdrop), amountToSend);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        //arrange
        console.log("user address : %s", user);
        uint256 startBalance = dogToken.balanceOf(user);
        bytes32 digest = merkleAirdrop.getMessageHash(user, amountToCollect);
        vm.prank(user);
        //sign a message 
        (uint8 v,bytes32 r,bytes32 s) = vm.sign(userPrivKey, digest);
        //gas payer calls claim using the signed message 
        //act
        merkleAirdrop.claim(user, amountToCollect, PROOF, v,r,s);
        vm.prank(gasPayer); 
        uint256 endingBalance = dogToken.balanceOf(user);
        console.log("Ending balance", endingBalance);
        //assert
        assertEq(endingBalance - startBalance, amountToCollect);
    }
}
