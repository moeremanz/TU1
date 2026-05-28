// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DN404Mirror} from "dn404/DN404Mirror.sol";

/**
 * @title IERC8004IdentityRegistry
 * @notice Minimal interface for the ERC-8004 Identity Registry.
 * 
 * Deployed via CREATE2 at the same address on all EVM chains:
 *   Mainnet: 0x8004A169FB4a3325136EB29fA0ceB6D2e539a432
 *   Testnet: 0x8004A816BFB912233c491671b3d84c89A494BD9e
 *
 * Full spec: https://eips.ethereum.org/EIPS/eip-8004
 */
interface IERC8004IdentityRegistry {
    /// @notice Register a new agent with an initial URI.
    /// @param to        Owner of the agent
    /// @param agentURI  URI pointing to agent registration file
    /// @return agentId  The newly minted agent ID (ERC-721 tokenId)
    function register(address to, string calldata agentURI) external returns (uint256 agentId);

    /// @notice Update the agent's URI.
    function setAgentURI(uint256 agentId, string calldata uri) external;

    /// @notice Get the agent's URI.
    function agentURI(uint256 agentId) external view returns (string memory);

    /// @notice Get on-chain metadata for a key.
    function getMetadata(uint256 agentId, string calldata key) external view returns (bytes memory);

    /// @notice Set on-chain metadata for a key.
    function setMetadata(uint256 agentId, string calldata key, bytes calldata value) external;

    /// @notice Set the agent's payment wallet (EIP-712 verified).
    function setAgentWallet(uint256 agentId, address wallet, bytes calldata signature) external;

    /// @notice Get the agent's payment wallet.
    function agentWalletOf(uint256 agentId) external view returns (address);

    /// @dev ERC-721
    function ownerOf(uint256 tokenId) external view returns (address);
}

/**
 * @title TU1Mirror
 * @notice DN-404 Mirror with ERC-8004 Trustless Agent Identity integration.
 * 
 * Every TU1 NFT (minted automatically when holding ≥100,000 TU1) doubles as an
 * ERC-8004 agent identity. The NFT owner can:
 *   - Set agent metadata (URI, wallet, attributes)
 *   - Register on the global ERC-8004 Identity Registry
 *   - Build reputation through the ERC-8004 Reputation Registry (future)
 * 
 * The global ERC-8004 registry is deployed via CREATE2 and exists at the same
 * address on all EVM chains including Base.
 */
contract TU1Mirror is DN404Mirror {

    // ═══════════════════════════════════════════════════
    // ERC-8004 IDENTITY REGISTRY
    // ═══════════════════════════════════════════════════

    /// @dev ERC-8004 Identity Registry (same address on all EVM chains via CREATE2).
    IERC8004IdentityRegistry public constant REGISTRY =
        IERC8004IdentityRegistry(0x8004A169FB4a3325136EB29fA0ceB6D2e539a432);

    // ═══════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════

    /// @dev Agent URI per token (agentId → IPFS/HTTPS URI).
    mapping(uint256 => string) private _agentURIs;

    /// @dev Whether this NFT has been registered on the global ERC-8004 registry.
    mapping(uint256 => bool) public registeredOnGlobal;

    /// @dev Additional key-value metadata per agent (agentId → key → value).
    mapping(uint256 => mapping(string => bytes)) private _metadata;

    // ═══════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════

    event AgentURIUpdated(uint256 indexed agentId, string uri);
    event AgentRegistered(uint256 indexed agentId, uint256 indexed registryAgentId);
    event AgentMetadataSet(uint256 indexed agentId, string key, bytes value);

    // ═══════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════

    constructor(address base) DN404Mirror(base) {}

    // ═══════════════════════════════════════════════════
    // ERC-8004: AGENT IDENTITY
    // ═══════════════════════════════════════════════════

    /**
     * @notice Set the agent URI for this NFT.
     * @param agentId Token ID (DN-404 NFT)
     * @param uri     URI pointing to agent registration file (JSON)
     * 
     * The URI should resolve to an ERC-8004 compliant registration file:
     * {
     *   "type": "agent",
     *   "name": "...",
     *   "description": "...",
     *   "image": "ipfs://...",
     *   "endpoints": [...],
     *   "attributes": {...}
     * }
     */
    function setAgentURI(uint256 agentId, string calldata uri) external {
        address owner = _tryOwnerOf(agentId);
        require(owner == msg.sender, "Not NFT owner");

        _agentURIs[agentId] = uri;
        emit AgentURIUpdated(agentId, uri);
    }

    /**
     * @notice Get the agent URI for this NFT.
     * @return URI string, or empty if not set
     */
    function getAgentURI(uint256 agentId) external view returns (string memory) {
        return _agentURIs[agentId];
    }

    /**
     * @notice Register this NFT's agent identity on the global ERC-8004 Identity Registry.
     * 
     * Once registered, the agent becomes discoverable across all chains that support ERC-8004.
     * The global registry mints a new ERC-721 token representing the agent identity.
     * 
     * Requirements:
     * - Caller must be the NFT owner
     * - Agent URI must be set first via setAgentURI()
     * - Cannot register the same agent twice
     */
    function registerOnGlobalRegistry(uint256 agentId) external {
        address owner = _tryOwnerOf(agentId);
        require(owner == msg.sender, "Not NFT owner");
        require(bytes(_agentURIs[agentId]).length > 0, "URI not set");
        require(!registeredOnGlobal[agentId], "Already registered");

        registeredOnGlobal[agentId] = true;
        uint256 registryAgentId = REGISTRY.register(owner, _agentURIs[agentId]);

        emit AgentRegistered(agentId, registryAgentId);
    }

    /**
     * @notice Set on-chain metadata for this agent.
     * @param agentId Token ID
     * @param key     Metadata key (e.g., "skills", "domains", "reputation")
     * @param value   Metadata value (bytes — can be ABI-encoded)
     * 
     * Reserved key "agentWallet" cannot be set via this function.
     * Use setAgentWallet() with EIP-712 signature instead.
     */
    function setMetadata(uint256 agentId, string calldata key, bytes calldata value) external {
        address owner = _tryOwnerOf(agentId);
        require(owner == msg.sender, "Not NFT owner");
        require(keccak256(bytes(key)) != keccak256(bytes("agentWallet")), "Use setAgentWallet()");

        _metadata[agentId][key] = value;
        emit AgentMetadataSet(agentId, key, value);
    }

    /**
     * @notice Get on-chain metadata for this agent.
     */
    function getMetadata(uint256 agentId, string calldata key) external view returns (bytes memory) {
        return _metadata[agentId][key];
    }

    // ═══════════════════════════════════════════════════
    // TOKEN URI
    // ═══════════════════════════════════════════════════

    /**
     * @notice Returns the token URI for a given token ID.
     * If an agent URI has been set, returns that (ERIC-8004 registration file).
     * Otherwise falls back to the default DN-404 URI.
     */
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        if (bytes(_agentURIs[id]).length > 0) {
            return _agentURIs[id];
        }
        return super.tokenURI(id);
    }

    // ═══════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════

    /**
     * @dev Get the owner of a token.
     * Uses DN404's `ownerAt()` which returns address(0) if the token doesn't exist.
     */
    function _tryOwnerOf(uint256 agentId) internal view returns (address) {
        return this.ownerAt(agentId);
    }
}
