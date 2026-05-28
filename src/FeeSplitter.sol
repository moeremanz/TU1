// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FeeSplitter
 * @notice Splits the Bankr creator share (0.684%) between Owner and Treasury.
 * 
 * Bankr sends the creator share fee (in ETH or TU1) to this contract.
 * FeeSplitter automatically forwards:
 *   - 70.76% to Owner Wallet (0.484% of total volume)
 *   - 29.24% to Agentic Wallet (0.200% of total volume)
 * 
 * This contract is set as the beneficiary/recipient in Bankr's fee configuration.
 */
contract FeeSplitter is Ownable {

    address public immutable ownerWallet;
    address public immutable agenticWallet;

    // Split ratios (basis points = 1/10000)
    uint256 public constant OWNER_SHARE = 7076; // 70.76% → 0.484%
    uint256 public constant TREASURY_SHARE = 2924; // 29.24% → 0.200%
    // Total = 10000 (100%)

    // Events
    event FeesDistributed(uint256 totalAmount, uint256 ownerAmount, uint256 treasuryAmount);
    event ETHWithdrawn(address indexed to, uint256 amount);

    constructor(address _ownerWallet, address _agenticWallet) Ownable(msg.sender) {
        require(_ownerWallet != address(0), "Owner wallet cannot be zero");
        require(_agenticWallet != address(0), "Agentic wallet cannot be zero");
        ownerWallet = _ownerWallet;
        agenticWallet = _agenticWallet;
    }

    /**
     * @notice Distribute received ETH between Owner and Treasury.
     * Anyone can call this to trigger distribution.
     */
    function distributeETH() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to distribute");

        uint256 ownerAmount = (balance * OWNER_SHARE) / 10000;
        uint256 treasuryAmount = balance - ownerAmount;

        (bool sentOwner, ) = payable(ownerWallet).call{value: ownerAmount}("");
        require(sentOwner, "Owner transfer failed");

        (bool sentTreasury, ) = payable(agenticWallet).call{value: treasuryAmount}("");
        require(sentTreasury, "Treasury transfer failed");

        emit FeesDistributed(balance, ownerAmount, treasuryAmount);
    }

    /**
     * @notice Distribute received ERC20 (e.g., TU1) between Owner and Treasury.
     * @param tokenAddress The ERC20 token address
     */
    function distributeERC20(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to distribute");

        uint256 ownerAmount = (balance * OWNER_SHARE) / 10000;
        uint256 treasuryAmount = balance - ownerAmount;

        require(token.transfer(ownerWallet, ownerAmount), "Owner transfer failed");
        require(token.transfer(agenticWallet, treasuryAmount), "Treasury transfer failed");

        emit FeesDistributed(balance, ownerAmount, treasuryAmount);
    }

    /**
     * @notice Accept ETH directly.
     */
    receive() external payable {}

    /**
     * @notice Emergency withdrawal of stuck ETH.
     */
    function emergencyWithdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "Transfer failed");
        emit ETHWithdrawn(owner(), balance);
    }
}
