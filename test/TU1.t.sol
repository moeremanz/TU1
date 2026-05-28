// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TU1} from "../src/TU1.sol";
import {TeamVesting} from "../src/TeamVesting.sol";
import {FeeSplitter} from "../src/FeeSplitter.sol";

/**
 * @title TU1Test
 * @notice Tests for all TU1 contracts.
 */
contract TU1Test is Test {

    TU1 public tu1;
    TeamVesting public vesting;
    FeeSplitter public splitter;

    address public deployer = address(0x1);
    address public ownerWallet = address(0x2);
    address public agenticWallet = address(0x3);
    address public user1 = address(0x4);
    address public user2 = address(0x5);

    function setUp() public {
        vm.startPrank(deployer);

        // Step 1: Deploy TU1 with dummy vesting address (70M goes to deployer temporarily)
        tu1 = new TU1(ownerWallet, deployer, agenticWallet);

        // Step 2: Deploy real TeamVesting with TU1 token address
        vesting = new TeamVesting(address(tu1));

        // Step 3: Transfer 70M TU1 from deployer to real vesting contract
        tu1.transfer(address(vesting), 70_000_000 * 10**18);

        // Step 4: Deploy FeeSplitter
        splitter = new FeeSplitter(ownerWallet, agenticWallet);

        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════
    // DEPLOY TESTS
    // ═══════════════════════════════════════════════════

    function test_Deploy_Allocations() public view {
        // TU1 constructor: deployer gets 250M LP + 70M (dummy vesting) = 320M
        // Then setUp transfers 70M from deployer to real vesting contract
        // So: deployer = 250M, vesting = 70M

        assertEq(tu1.balanceOf(deployer), 250_000_000 * 10**18, "Deployer balance wrong");

        // Owner gets 30M
        assertEq(tu1.balanceOf(ownerWallet), 30_000_000 * 10**18, "Owner balance wrong");

        // Vesting gets 70M (transferred from deployer in setUp)
        assertEq(tu1.balanceOf(address(vesting)), 70_000_000 * 10**18, "Vesting balance wrong");

        // Contract holds 650M (100M treasury + 550M mint)
        assertEq(tu1.balanceOf(address(tu1)), 650_000_000 * 10**18, "Contract balance wrong");

        // Total supply = deployer(250M) + owner(30M) + vesting(70M) + contract(650M) = 1B
        assertEq(tu1.totalSupply(), 1_000_000_000 * 10**18, "Total supply wrong");
    }

    function test_Deploy_TotalSupply() public view {
        assertEq(tu1.totalSupply(), 1_000_000_000 * 10**18);
    }

    // ═══════════════════════════════════════════════════
    // MINT TESTS
    // ═══════════════════════════════════════════════════

    function test_Mint_Basic() public {
        vm.startPrank(deployer);
        tu1.openMint();

        bytes32 riddleHash = keccak256("answer42");
        tu1.mint(user1, 3, riddleHash);
        vm.stopPrank();

        assertEq(tu1.balanceOf(user1), 300_000 * 10**18); // 3 × 100K
        assertEq(tu1.mintedCount(user1), 3);
        assertEq(tu1.totalMintsExecuted(), 3);
    }

    function test_Mint_Max10() public {
        vm.startPrank(deployer);
        tu1.openMint();

        bytes32 r1 = keccak256("a");
        tu1.mint(user1, 10, r1);
        vm.stopPrank();

        assertEq(tu1.mintedCount(user1), 10);
        assertEq(tu1.balanceOf(user1), 1_000_000 * 10**18); // 10 × 100K
    }

    function test_Revert_Mint_ExceedsMax() public {
        vm.startPrank(deployer);
        tu1.openMint();

        bytes32 r1 = keccak256("a");
        tu1.mint(user1, 10, r1);

        bytes32 r2 = keccak256("b");
        vm.expectRevert("Max 10 mints per wallet");
        tu1.mint(user1, 1, r2);
        vm.stopPrank();
    }

    function test_Revert_Mint_RiddleReuse() public {
        vm.startPrank(deployer);
        tu1.openMint();

        bytes32 riddleHash = keccak256("usedRiddle");
        tu1.mint(user1, 1, riddleHash);

        vm.expectRevert("Riddle already used");
        tu1.mint(user2, 1, riddleHash);
        vm.stopPrank();
    }

    function test_Revert_Mint_BeforeOpen() public {
        vm.startPrank(deployer);
        bytes32 r = keccak256("shouldFail");
        vm.expectRevert("Mint not opened");
        tu1.mint(user1, 1, r);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════
    // TREASURY TESTS
    // ═══════════════════════════════════════════════════

    function test_Treasury_ReleaseAfterMintEnd() public {
        vm.startPrank(deployer);
        tu1.openMint();
        
        // Warp past 3 days
        vm.warp(block.timestamp + 4 days);
        
        tu1.releaseTreasury();
        vm.stopPrank();

        assertEq(tu1.balanceOf(agenticWallet), 100_000_000 * 10**18);
        assertTrue(tu1.treasuryReleased());
    }

    function test_Revert_Treasury_BeforeMintEnd() public {
        vm.startPrank(deployer);
        tu1.openMint();
        
        vm.expectRevert("Mint still active");
        tu1.releaseTreasury();
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════
    // BURN TESTS
    // ═══════════════════════════════════════════════════

    function test_Burn_Tokens() public {
        vm.startPrank(deployer);
        tu1.openMint();

        bytes32 r = keccak256("burnTest");
        tu1.mint(user1, 5, r);
        vm.stopPrank();

        vm.startPrank(user1);
        tu1.burn(100_000 * 10**18); // Burn 100K
        vm.stopPrank();

        assertEq(tu1.balanceOf(user1), 400_000 * 10**18);
    }

    // ═══════════════════════════════════════════════════
    // VESTING TESTS
    // ═══════════════════════════════════════════════════

    function test_Vesting_Cliff() public {
        address teamMember = address(0x6);
        uint256 allocation = 10_000_000 * 10**18; // 10M TU1
        
        // Deployer adds beneficiary to vesting
        // First need to update vesting with actual TU1 address
        // Note: vesting was deployed with placeholder, but TU1 constructor already minted 70M to it
        
        vm.startPrank(deployer);
        vesting.addBeneficiary(teamMember, allocation);
        
        // During cliff — nothing claimable
        assertEq(vesting.claimableAmount(teamMember), 0);
        
        // Warp past cliff
        vm.warp(block.timestamp + 91 days);
        
        // Should be partially vested
        assertGt(vesting.claimableAmount(teamMember), 0);
        assertLt(vesting.claimableAmount(teamMember), allocation);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════
    // FEE SPLITTER TESTS
    // ═══════════════════════════════════════════════════

    function test_FeeSplitter_ETHDistribution() public {
        // Send ETH to FeeSplitter
        vm.deal(address(splitter), 1 ether);
        
        uint256 ownerBefore = ownerWallet.balance;
        uint256 treasuryBefore = agenticWallet.balance;
        
        splitter.distributeETH();
        
        uint256 ownerAfter = ownerWallet.balance;
        uint256 treasuryAfter = agenticWallet.balance;
        
        // Owner should get 70.76%
        assertEq(ownerAfter - ownerBefore, 0.7076 ether);
        
        // Treasury gets 29.24%
        assertEq(treasuryAfter - treasuryBefore, 0.2924 ether);
    }
}
