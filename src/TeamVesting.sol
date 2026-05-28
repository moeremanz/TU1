// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TeamVesting
 * @notice Handles 70M TU1 team token vesting.
 * 
 * Schedule:
 * - 3-month cliff: no tokens claimable
 * - 3-month linear vest: tokens unlock block-by-block
 * - Fully vested at month 6
 * 
 * Beneficiaries can claim their share anytime during or after vesting.
 * Owner can add/remove beneficiaries and their allocations.
 */
contract TeamVesting is Ownable {

    // ═══════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════

    uint256 public constant CLIFF_DURATION  = 90 days;   // 3 months
    uint256 public constant VEST_DURATION   = 90 days;   // 3 months
    uint256 public constant TOTAL_DURATION  = CLIFF_DURATION + VEST_DURATION; // 180 days

    IERC20 public immutable token;  // TU1 token address

    // ═══════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════

    uint256 public startTime;                            // When vesting started (deploy time)
    uint256 public totalAllocated;                        // Total TU1 allocated to beneficiaries
    uint256 public totalClaimed;                          // Total TU1 claimed so far

    address[] public beneficiaries;
    mapping(address => uint256) public allocations;       // Beneficiary → allocation
    mapping(address => uint256) public claimed;           // Beneficiary → amount claimed
    mapping(address => bool)    public isBeneficiary;

    // Events
    event BeneficiaryAdded(address indexed beneficiary, uint256 allocation);
    event BeneficiaryRemoved(address indexed beneficiary);
    event TokensClaimed(address indexed beneficiary, uint256 amount);
    event VestingStarted(uint256 startTime);

    // ═══════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════

    /**
     * @param _token TU1 token address.
     * 
     * Contract automatically receives 70M TU1 from TU1 constructor.
     * startTime is set when the first beneficiary is added.
     */
    constructor(address _token) Ownable(msg.sender) {
        require(_token != address(0), "Token cannot be zero");
        token = IERC20(_token);
    }

    // ═══════════════════════════════════════════════════
    // BENEFICIARY MANAGEMENT (owner only)
    // ═══════════════════════════════════════════════════

    /**
     * @notice Add a beneficiary with their allocation.
     * @param beneficiary  Wallet address
     * @param allocation   Amount of TU1 (in wei, 18 decimals)
     * 
     * First call starts the vesting timer.
     * Cannot exceed total received token balance.
     */
    function addBeneficiary(address beneficiary, uint256 allocation) external onlyOwner {
        require(beneficiary != address(0), "Beneficiary cannot be zero");
        require(allocation > 0, "Allocation must be > 0");
        require(!isBeneficiary[beneficiary], "Already a beneficiary");
        require(totalAllocated + allocation <= token.balanceOf(address(this)) + totalClaimed, 
                "Exceeds contract balance");

        if (startTime == 0) {
            startTime = block.timestamp;
            emit VestingStarted(block.timestamp);
        }

        beneficiaries.push(beneficiary);
        isBeneficiary[beneficiary] = true;
        allocations[beneficiary] = allocation;
        totalAllocated += allocation;

        emit BeneficiaryAdded(beneficiary, allocation);
    }

    /**
     * @notice Remove a beneficiary (their unclaimed tokens become available for redistribution).
     * @param beneficiary Wallet address to remove
     */
    function removeBeneficiary(address beneficiary) external onlyOwner {
        require(isBeneficiary[beneficiary], "Not a beneficiary");

        isBeneficiary[beneficiary] = false;
        allocations[beneficiary] = 0;
        
        // Remove from array
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i] == beneficiary) {
                beneficiaries[i] = beneficiaries[beneficiaries.length - 1];
                beneficiaries.pop();
                break;
            }
        }

        emit BeneficiaryRemoved(beneficiary);
    }

    // ═══════════════════════════════════════════════════
    // VESTING CALCULATION
    // ═══════════════════════════════════════════════════

    /**
     * @notice Calculate vested amount for a beneficiary.
     * @param beneficiary Wallet address to check
     * @return Vested amount (total claimable so far)
     */
    function vestedAmount(address beneficiary) public view returns (uint256) {
        if (!isBeneficiary[beneficiary]) return 0;
        if (startTime == 0) return 0;

        uint256 allocation = allocations[beneficiary];

        // Cliff period — nothing vested
        if (block.timestamp < startTime + CLIFF_DURATION) {
            return 0;
        }

        // After total duration — fully vested
        if (block.timestamp >= startTime + TOTAL_DURATION) {
            return allocation;
        }

        // During linear vest period
        uint256 elapsed = block.timestamp - startTime - CLIFF_DURATION;
        return (allocation * elapsed) / VEST_DURATION;
    }

    /**
     * @notice Calculate claimable amount for a beneficiary.
     * @param beneficiary Wallet address to check
     * @return Claimable amount (vested - already claimed)
     */
    function claimableAmount(address beneficiary) public view returns (uint256) {
        return vestedAmount(beneficiary) - claimed[beneficiary];
    }

    // ═══════════════════════════════════════════════════
    // CLAIM
    // ═══════════════════════════════════════════════════

    /**
     * @notice Claim vested TU1 tokens. Anyone can claim on behalf of a beneficiary.
     * @param beneficiary Wallet address to claim for
     */
    function claim(address beneficiary) external {
        require(isBeneficiary[beneficiary], "Not a beneficiary");
        
        uint256 claimable = claimableAmount(beneficiary);
        require(claimable > 0, "Nothing to claim");

        claimed[beneficiary] += claimable;
        totalClaimed += claimable;

        require(token.transfer(beneficiary, claimable), "Transfer failed");

        emit TokensClaimed(beneficiary, claimable);
    }

    /**
     * @notice Get all beneficiaries and their claimable amounts.
     */
    function getBeneficiaries() external view returns (address[] memory, uint256[] memory) {
        uint256 len = beneficiaries.length;
        address[] memory addrs = new address[](len);
        uint256[] memory amounts = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            addrs[i] = beneficiaries[i];
            amounts[i] = claimableAmount(beneficiaries[i]);
        }

        return (addrs, amounts);
    }

    // ═══════════════════════════════════════════════════
    // EMERGENCY
    // ═══════════════════════════════════════════════════

    /**
     * @notice In case something goes wrong — recover any ERC20 sent here accidentally.
     */
    function recoverERC20(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(token), "Cannot recover vesting token directly");
        IERC20(tokenAddress).transfer(owner(), amount);
    }
}
