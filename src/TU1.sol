// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TU1
 * @notice TU1 Token with riddle-based mint, batch minting, automatic treasury release, and burn mechanism.
 * 
 * Wallet Architecture:
 * - Deployer Wallet: Receives 250M LP allocation at deploy (for Bankr setup)
 * - Owner Wallet: Receives 30M TU1 (unlocked at TGE)
 * - Vesting Contract: Receives 70M TU1 (3mo cliff + 3mo linear vest)
 * - Agentic Wallet: Receives 100M Treasury post-mint (automatic release)
 * - Mint Supply: 550M TU1 stays in contract until minted or burned
 */
contract TU1 is ERC20, Ownable, ReentrancyGuard {

    // ═══════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════

    uint256 public constant TOTAL_SUPPLY      = 1_000_000_000 * 10**18; // 1B
    uint256 public constant MINT_SUPPLY       = 550_000_000 * 10**18;  // 55%
    uint256 public constant LP_ALLOCATION     = 250_000_000 * 10**18;  // 25%
    uint256 public constant TREASURY_ALLOC    = 100_000_000 * 10**18;  // 10%
    uint256 public constant TEAM_ALLOC        = 100_000_000 * 10**18;  // 10%

    uint256 public constant TOKENS_PER_MINT         = 100_000 * 10**18; // 100K TU1
    uint256 public constant MAX_MINT_PER_WALLET      = 10;
    uint256 public constant TOTAL_MINTS              = 5_500;
    
    uint256 public constant MINT_PERIOD             = 3 days;
    uint256 public constant LP_LOCK_DURATION        = 365 days;
    uint256 public constant TEAM_CLIFF_DURATION     = 90 days;
    uint256 public constant TEAM_VEST_DURATION      = 90 days; // 3mo linear after cliff

    // ═══════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════

    address public immutable ownerWallet;
    address public immutable agenticWallet;
    address public immutable vestingContract;
    
    // Mint tracking
    mapping(address => uint256) public mintedCount;        // wallet → count
    mapping(bytes32 => bool)    public usedRiddles;         // riddleHash → used
    uint256                     public totalMintsExecuted;  // total mints performed
    uint256                     public mintStartTime;       // block.timestamp when mint opened
    
    // Flags
    bool public mintOpened;                                  // Mint open/closed
    bool public treasuryReleased;                            // Treasury already sent to agentic wallet

    // Signature mint
    address public signer;                                   // Address authorized to sign mint permits
    mapping(address => uint256) public nonces;               // Per-user nonce for replay protection

    // EIP-712
    bytes32 private constant MINT_TYPEHASH = keccak256(
        "MintPermit(address to,uint256 amount,bytes32 riddleHash,uint256 nonce,uint256 deadline)"
    );

    // Events
    event MintOpened(uint256 timestamp);
    event MintClosed(uint256 timestamp);
    event TokensMinted(address indexed to, uint256 amount, uint256 count, bytes32 riddleHash);
    event TreasuryReleased(address indexed agenticWallet, uint256 amount);
    event UnsoldBurned(uint256 amount);

    // ═══════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════

    /**
     * @param _ownerWallet     Address receiving 30M TU1 (unlocked at TGE)
     * @param _vestingContract Address of TeamVesting contract receiving 70M TU1
     * @param _agenticWallet   Address of treasury wallet (receives 100M post-mint)
     * 
     * Deployer wallet (msg.sender) receives 250M TU1 for LP/ Bankr setup.
     */
    constructor(
        address _ownerWallet,
        address _vestingContract,
        address _agenticWallet
    ) ERC20("TU1", "TU1") Ownable(msg.sender) {
        require(_ownerWallet != address(0), "Owner wallet cannot be zero");
        require(_vestingContract != address(0), "Vesting contract cannot be zero");
        require(_agenticWallet != address(0), "Agentic wallet cannot be zero");

        ownerWallet = _ownerWallet;
        vestingContract = _vestingContract;
        agenticWallet = _agenticWallet;

        // Distribute allocations at deploy
        _mint(msg.sender, LP_ALLOCATION);       // 250M → Deployer Wallet (for Bankr LP)
        _mint(ownerWallet, 30_000_000 * 10**18); // 30M → Owner Wallet (unlocked at TGE)
        _mint(vestingContract, 70_000_000 * 10**18); // 70M → Vesting Contract

        // Treasury & mint supply stay in contract
        _mint(address(this), TREASURY_ALLOC + MINT_SUPPLY); // 100M treasury + 550M mint = 650M
    }

    // ═══════════════════════════════════════════════════
    // MINT — RIDDLE-BASED (onlyOwner / Agent)
    // ═══════════════════════════════════════════════════

    /**
     * @notice Open the mint period. Call once when ready.
     */
    function openMint() external onlyOwner {
        require(!mintOpened, "Mint already opened");
        mintOpened = true;
        mintStartTime = block.timestamp;
        emit MintOpened(block.timestamp);
    }

    /**
     * @notice Mint TU1 tokens to a user.
     * @param to         Wallet address receiving the tokens
     * @param amount     Number of mints (1 = 100K TU1, max 10)
     * @param riddleHash Hash of the riddle answer (prevents replay)
     * 
     * Only callable by owner/agent. User must solve a riddle off-chain,
     * submit answer via the agent, and agent calls this function.
     * Max 10 mints per wallet — we batch them so it costs 1 gas call.
     */
    function mint(address to, uint256 amount, bytes32 riddleHash) external onlyOwner {
        require(mintOpened, "Mint not opened");
        require(block.timestamp <= mintStartTime + MINT_PERIOD, "Mint period ended");
        require(amount > 0 && amount <= MAX_MINT_PER_WALLET, "Invalid mint amount");
        require(mintedCount[to] + amount <= MAX_MINT_PER_WALLET, "Max 10 mints per wallet");
        require(!usedRiddles[riddleHash], "Riddle already used");
        
        uint256 tokenAmount = amount * TOKENS_PER_MINT;
        require(totalMintsExecuted + amount <= TOTAL_MINTS, "Mint supply exhausted");
        require(balanceOf(address(this)) >= tokenAmount, "Insufficient contract balance");

        // Mark riddle as used
        usedRiddles[riddleHash] = true;
        mintedCount[to] += amount;
        totalMintsExecuted += amount;

        // Transfer tokens from contract to user
        _transfer(address(this), to, tokenAmount);

        emit TokensMinted(to, tokenAmount, amount, riddleHash);
    }

    /**
     * @notice Force close mint (e.g., if sold out before 3 days).
     */
    function closeMint() external onlyOwner {
        require(mintOpened, "Mint not opened");
        mintOpened = false;
        emit MintClosed(block.timestamp);
    }

    // ═══════════════════════════════════════════════════
    // SIGNATURE MINT — USER EXECUTED, AGENT AUTHORIZED
    // ═══════════════════════════════════════════════════

    /**
     * @notice Set the signer address (agent key) for mint permits.
     * @param _signer Address that signs mint permits
     */
    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "Signer cannot be zero");
        signer = _signer;
    }

    /**
     * @notice Users call this directly — they pay gas.
     * Agent must have signed a permit off-chain after verifying the riddle answer.
     * 
     * Flow:
     * 1. User asks agent for a riddle
     * 2. User solves riddle, submits answer to agent
     * 3. Agent verifies → signs a permit → sends signature to user
     * 4. User calls submitMint() — gas paid by user, mint executed
     * 
     * @param amount    Number of mints (1-10)
     * @param riddleHash Hash of the riddle answer
     * @param deadline  Timestamp after which this permit expires
     * @param signature Agent's signature authorizing this mint
     */
    function submitMint(
        uint256 amount,
        bytes32 riddleHash,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant {
        require(block.timestamp <= deadline, "Permit expired");
        require(mintOpened, "Mint not opened");
        require(block.timestamp <= mintStartTime + MINT_PERIOD, "Mint period ended");
        require(amount > 0 && amount <= MAX_MINT_PER_WALLET, "Invalid amount");
        require(mintedCount[msg.sender] + amount <= MAX_MINT_PER_WALLET, "Max 10 per wallet");
        require(!usedRiddles[riddleHash], "Riddle already used");
        
        uint256 tokenAmount = amount * TOKENS_PER_MINT;
        require(totalMintsExecuted + amount <= TOTAL_MINTS, "Mint supply exhausted");
        require(balanceOf(address(this)) >= tokenAmount, "Insufficient contract balance");

        // Verify signature: agent signed (to, amount, riddleHash, nonce, deadline)
        bytes32 permitHash = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encode(
                MINT_TYPEHASH,
                msg.sender,
                amount,
                riddleHash,
                nonces[msg.sender],
                deadline
            ))
        );

        address recoveredSigner = ECDSA.recover(permitHash, signature);
        require(recoveredSigner == signer, "Invalid signature");

        // Execute mint
        usedRiddles[riddleHash] = true;
        mintedCount[msg.sender] += amount;
        totalMintsExecuted += amount;
        nonces[msg.sender]++;

        _transfer(address(this), msg.sender, tokenAmount);

        emit TokensMinted(msg.sender, tokenAmount, amount, riddleHash);
    }

    /**
     * @notice Check if mint period has ended.
     */
    function isMintEnded() public view returns (bool) {
        if (!mintOpened) return true; // closed manually
        return block.timestamp > mintStartTime + MINT_PERIOD;
    }

    // ═══════════════════════════════════════════════════
    // TREASURY — AUTOMATIC RELEASE
    // ═══════════════════════════════════════════════════

    /**
     * @notice Anyone can trigger this after mint ends.
     * Sends 100M TU1 treasury to agentic wallet.
     * Remaining unsold mint tokens are burned.
     */
    function releaseTreasury() external {
        require(isMintEnded(), "Mint still active");
        require(!treasuryReleased, "Treasury already released");

        treasuryReleased = true;

        // Send treasury allocation to agentic wallet
        _transfer(address(this), agenticWallet, TREASURY_ALLOC);
        emit TreasuryReleased(agenticWallet, TREASURY_ALLOC);

        // Burn any remaining unsold mint tokens
        uint256 unsoldBalance = balanceOf(address(this));
        if (unsoldBalance > 0) {
            _burn(address(this), unsoldBalance);
            emit UnsoldBurned(unsoldBalance);
        }
    }

    // ═══════════════════════════════════════════════════
    // BURN — FOR SUBSCRIPTION BURN
    // ═══════════════════════════════════════════════════

    /**
     * @notice Burn TU1 tokens (for TU1 Crypto Graph subscription burn).
     */
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        _burn(msg.sender, amount);
    }

    /**
     * @notice Batch burn — for agent to burn subscription payments.
     */
    function burnFrom(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be > 0");
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    // ═══════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════

    /**
     * @notice Remaining mints available.
     */
    function remainingMints() external view returns (uint256) {
        return TOTAL_MINTS - totalMintsExecuted;
    }

    /**
     * @notice Remaining mint supply in contract.
     */
    function remainingMintSupply() external view returns (uint256) {
        return balanceOf(address(this)) - TREASURY_ALLOC;
    }
}
