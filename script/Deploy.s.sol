// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2 as console} from "forge-std/Script.sol";
import {TU1} from "../src/TU1.sol";
import {TeamVesting} from "../src/TeamVesting.sol";
import {FeeSplitter} from "../src/FeeSplitter.sol";

/**
 * @title DeployTU1
 * @notice Deploy all TU1 contracts in sequence.
 * 
 * Usage:
 *   forge script script/Deploy.s.sol --rpc-url base_sepolia --broadcast
 * 
 * Set env vars:
 *   OWNER_ADDRESS=0x...       👑 Owner wallet
 *   AGENTIC_ADDRESS=0x...     🤖 Agentic wallet  
 *   DEPLOYER_PRIVATE_KEY=0x... 🔵 Deployer private key
 */
contract DeployTU1 is Script {

    function run() external {
        // Read deployment addresses from env
        address ownerWallet = vm.envAddress("OWNER_ADDRESS");
        address agenticWallet = vm.envAddress("AGENTIC_ADDRESS");
        
        vm.startBroadcast();

        // Step 1: Deploy TeamVesting first (need its address for TU1 constructor)
        TeamVesting vesting = new TeamVesting(address(0)); // placeholder — updated after TU1 deploy
        address vestingAddr = address(vesting);

        // Step 2: Deploy TU1 token
        TU1 tu1 = new TU1(ownerWallet, vestingAddr, agenticWallet);
        
        // Step 3: Update TeamVesting with actual TU1 token address
        // (Vesting contract receives 70M TU1 from TU1 constructor)
        // Note: need to add beneficiaries separately via vesting.addBeneficiary()

        // Step 4: Deploy FeeSplitter
        FeeSplitter splitter = new FeeSplitter(ownerWallet, agenticWallet);

        vm.stopBroadcast();

        // Print deployment summary
        console.log("=== TU1 Deployment Summary ===");
        console.log("TU1 Token:        ", address(tu1));
        console.log("TeamVesting:      ", vestingAddr);
        console.log("FeeSplitter:      ", address(splitter));
        console.log("Owner Wallet:     ", ownerWallet);
        console.log("Agentic Wallet:   ", agenticWallet);
        console.log("Deployer Wallet:  ", vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY")));
        console.log("");
        console.log("Allocation at deploy:");
        console.log("250M LP to Deployer");
        console.log("30M Owner to Owner");
        console.log("70M Vesting to Vesting");
        console.log("100M Treasury to Contract (release post-mint)");
        console.log("550M Mint to Contract");
    }
}
