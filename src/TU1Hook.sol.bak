// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {SafeCast} from "v4-core/src/libraries/SafeCast.sol";
import {Currency} from "v4-core/src/types/Currency.sol";

/**
 * @title TU1Hook
 * @notice Uniswap V4 Hook for TU1 dynamic fee structure.
 * 
 * Features:
 * - Dynamic fee: 1% (low volume < $5K/day) or 1.5% (high volume ≥ $5K/day)
 * - Volume tracking (resets every 24 hours)
 * - Emergency pause for safety
 * - Owner adjustable threshold and fee rates
 * 
 * Deployed as a hook on the TU1/WETH (or TU1/USDC) pool.
 */
contract TU1Hook is BaseHook {

    using SafeCast for *;
    using LPFeeLibrary for uint24;

    // ═══════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════

    // Volume tracking
    uint256 public dailyVolume;          // Accumulated volume in USD (scaled)
    uint256 public lastReset;             // Last volume reset timestamp
    
    // Fee configuration
    uint256 public threshold = 5_000 * 10**18; // $5K USD (in wei-scaled)
    uint24  public lowFee  = 10000;             // 1.00% (in basis points * 100)
    uint24  public highFee = 15000;             // 1.50%
    
    // Safety
    bool    public paused;
    
    // Owner
    address public feeOwner;

    // Events
    event VolumeUpdated(uint256 newVolume);
    event VolumeReset(uint256 timestamp);
    event ThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event FeesUpdated(uint24 oldLow, uint24 oldHigh, uint24 newLow, uint24 newHigh);
    event Paused(bool isPaused);
    event EmergencyWithdraw(address indexed to, uint256 amount);

    // ═══════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════

    modifier onlyFeeOwner() {
        require(msg.sender == feeOwner, "Not fee owner");
        _;
    }

    // ═══════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════

    constructor(IPoolManager _poolManager, address _feeOwner) BaseHook(_poolManager) {
        require(_feeOwner != address(0), "Fee owner cannot be zero");
        feeOwner = _feeOwner;
        lastReset = block.timestamp;
    }

    // ═══════════════════════════════════════════════════
    // HOOK PERMISSIONS
    // ═══════════════════════════════════════════════════

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,      // ✅ Track volume + pause check
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnsDelta: false,
            afterSwapReturnsDelta: false,
            afterAddLiquidityReturnsDelta: false,
            afterRemoveLiquidityReturnsDelta: false
        });
    }

    // ═══════════════════════════════════════════════════
    // DYNAMIC FEE
    // ═══════════════════════════════════════════════════

    /**
     * @notice Returns the dynamic fee based on 24h volume.
     * Called by PoolManager during swaps.
     */
    function _getFee(PoolKey calldata, address, address, uint256) internal view returns (uint24) {
        if (dailyVolume < threshold) {
            return lowFee;   // 1.00% — low volume mode
        } else {
            return highFee;  // 1.50% — high volume mode
        }
    }

    // ═══════════════════════════════════════════════════
    // BEFORE SWAP
    // ═══════════════════════════════════════════════════

    function _beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    ) internal override returns (bytes4, BeforeSwapDelta, uint24) {
        // Emergency pause
        require(!paused, "Hook is paused");

        // Reset volume every 24 hours
        if (block.timestamp >= lastReset + 24 hours) {
            dailyVolume = 0;
            lastReset = block.timestamp;
            emit VolumeReset(block.timestamp);
        }

        // Estimate swap volume (simplified: amountSpecified = USD value approximation)
        // In production, use an oracle or exact USD conversion
        uint256 swapAmount = params.amountSpecified < 0 
            ? uint256(-params.amountSpecified) 
            : uint256(params.amountSpecified);
        
        // Accumulate volume
        dailyVolume += swapAmount;
        emit VolumeUpdated(dailyVolume);

        // Get dynamic fee
        uint24 fee = _getFee(key, address(0), address(0), 0);

        return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(0, 0), fee);
    }

    // ═══════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════

    /**
     * @notice Update volume threshold ($5K default).
     */
    function setThreshold(uint256 newThreshold) external onlyFeeOwner {
        require(newThreshold > 0, "Threshold must be > 0");
        uint256 oldThreshold = threshold;
        threshold = newThreshold;
        emit ThresholdUpdated(oldThreshold, newThreshold);
    }

    /**
     * @notice Update fee rates.
     */
    function setFees(uint24 newLowFee, uint24 newHighFee) external onlyFeeOwner {
        require(newLowFee > 0 && newHighFee > newLowFee, "Invalid fee rates");
        uint24 oldLow = lowFee;
        uint24 oldHigh = highFee;
        lowFee = newLowFee;
        highFee = newHighFee;
        emit FeesUpdated(oldLow, oldHigh, newLowFee, newHighFee);
    }

    /**
     * @notice Pause/unpause swapping.
     */
    function setPaused(bool isPaused) external onlyFeeOwner {
        paused = isPaused;
        emit Paused(isPaused);
    }

    // ═══════════════════════════════════════════════════
    // EMERGENCY
    // ═══════════════════════════════════════════════════

    /**
     * @notice Withdraw stuck ETH from the hook.
     */
    function emergencyWithdraw(address to) external onlyFeeOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = payable(to).call{value: balance}("");
        require(sent, "Withdraw failed");
        emit EmergencyWithdraw(to, balance);
    }

    /**
     * @notice Accept ETH.
     */
    receive() external payable {}
}
