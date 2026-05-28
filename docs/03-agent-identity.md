# 03 — Agent Identity (ERC-8004) 🆔

> *Every TU1 NFT is an agent identity registered on the global ERC-8004 Identity Registry on Base.*
> *Each holder owns a verifiable on-chain agent.*

---

## What is ERC-8004?

ERC-8004: **Trustless Agents** — a proposed Ethereum standard for discovering, choosing, and trusting AI agents on-chain. It defines three registries:

| Registry | Purpose |
|----------|---------|
| **Identity Registry** | On-chain agent registration (ERC-721 + metadata) |
| **Reputation Registry** | Feedback and scoring system |
| **Validation Registry** | Independent validator hooks |

TU1 uses the **global ERC-8004 Identity Registry** already deployed on Base — TU1Mirror calls this external registry, not a custom one.

---

## Global Registry Address

| Network | Address | Deploy Method |
|---------|---------|--------------|
| **Base Mainnet** | `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` | CREATE2 (deterministic) |
| **Base Sepolia** | `0x8004A816BFB912233c491671b3d84c89A494BD9e` | CREATE2 (deterministic) |

> Same address across all EVM chains thanks to CREATE2.

---

## Architecture

```
TU1Mirror.sol (DN-404 Mirror)
│
├── DN-404 Layer ─── ERC-721 (NFT auto-mint/burn with TU1 balance)
│   ├── tokenURI() → ERC-8004 registration URI
│   └── transfer hooks → auto-sync with registry
│
├── ERC-8004 Layer ─── Calls GLOBAL Identity Registry (0x8004A169...)
│   ├── registerOnGlobalRegistry() → registers NFT as agent
│   ├── setAgentURI() → updates agent metadata on registry
│   ├── getMetadata() / setMetadata() → on-chain agent data
│   ├── agentWallet → payment address for agent services
│   └── ERC-8004 Interface compliance
│
└── Future Layer ── Reputation + Validation hooks (Phase 6)
```

### Contract Interaction

```
┌──────────────┐         ┌──────────────────┐         ┌─────────────────────────┐
│  TU1Mirror   │ ──────► │ ERC-8004 Identity│         │  Global ERC-8004        │
│  (DN-404)    │  calls  │  Registry        │         │  Ecosystem (other       │
│              │         │  0x8004A169...   │         │  projects)              │
│  tokenURI →  │         │                  │ ◄────── │                         │
│  ERC-8004    │         │  registerAgent() │  query  │  Discover agents        │
│  metadata    │         │  setAgentURI()   │         │  Trust verification     │
│              │         │  getAgent()      │         │  Cross-project agents   │
└──────────────┘         └──────────────────┘         └─────────────────────────┘
```

> **Why external registry?** Being on the global ERC-8004 registry means TU1 agents are discoverable by other projects. An agent from another ecosystem can find and interact with TU1 agents — interop.

---

## Agent Registration Flow

When a user mints their first 100,000 TU1 (which creates an NFT via DN-404):

1. **NFT is minted** via DN-404 auto-mint (mirror contract)
2. **`_afterTokenTransfer()` hook fires** in TU1Mirror
3. **`registerOnGlobalRegistry()` is called** → registers `agentId` on ERC-8004 global registry
4. **`tokenURI()` resolves** to an agent registration file hosted on IPFS/Arweave

### Registration File

```json
{
  "type": "agent",
  "name": "TU1 Agent #1",
  "description": "TU1 agent identity — solves riddles and earns rewards",
  "image": "ipfs://bafybei...",
  "endpoints": [
    {
      "type": "a2a",
      "url": "https://agent.tu1.io/a2a",
      "version": "1.0"
    }
  ],
  "attributes": {
    "mints": 1,
    "riddles_solved": 1,
    "reputation": 0
  }
}
```

---

## Agent Ownership

| Action | Effect |
|--------|--------|
| **Buy 100K TU1** | Mint new NFT + register on ERC-8004 registry |
| **Sell TU1 below 100K** | NFT burns → deregister from registry |
| **Transfer NFT** | Registry updates owner |
| **Set agentURI** | Update agent metadata on registry (owner only) |
| **Set agentWallet** | Change payment address (EIP-712 verified) |

---

## Metadata Functions (on TU1Mirror)

These are convenience functions that internally call the ERC-8004 registry:

### Get Metadata

```solidity
function getMetadata(uint256 agentId, string calldata key)
    external view returns (bytes memory);
```

Returns on-chain metadata for a given agent ID and key.

### Set Metadata

```solidity
function setMetadata(uint256 agentId, string calldata key, bytes calldata value)
    external;
```

Sets on-chain metadata. Reverts if caller is not the NFT owner or approved operator.

**Reserved key:** `agentWallet` — cannot be set via `setMetadata()`. Must use `setAgentWallet()`.

### Set Agent Wallet

```solidity
function setAgentWallet(uint256 agentId, address wallet, bytes calldata signature)
    external;
```

Sets the payment address for the agent. Requires EIP-712 signature from the new wallet proving ownership.

### Register on Global Registry

```solidity
function registerOnGlobalRegistry(uint256 agentId) internal;
```

Auto-called on every NFT mint. Registers the agent in the global ERC-8004 Identity Registry.

---

## Agent Capabilities

Each TU1 agent inherits capabilities from the TU1 ecosystem:

| Capability | Description |
|------------|-------------|
| 🤖 **Riddle Solving** | Agent can solve riddles to mint TU1 |
| 📊 **Crypto Graph** | Agent can subscribe to daily market briefings |
| 🗳️ **Future: Governance** | Agent identity may be used for voting |
| 🏆 **Future: Staking** | Agent identity may boost staking rewards |

---

## Cross-Project Interoperability

Because TU1 uses the **global ERC-8004 registry** (same one used by other projects like Khora/BOOA):

| Scenario | How It Works |
|----------|-------------|
| **Another project queries TU1 agents** | Calls `getAgent(agentId)` on the same registry |
| **TU1 agent earns reputation elsewhere** | Reputation Registry records it on the same agentId |
| **Wallet holds agents from multiple projects** | All registered on one global registry — unified view |
| **Agent-to-agent interaction** | A2A endpoints discoverable via registry metadata |

---

## Smart Contract: TU1Mirror.sol

```solidity
interface IIdentityRegistry {
    function registerAgent(
        uint256 agentId,
        address agentAddress,
        string calldata agentURI
    ) external returns (bool);
    
    function updateAgentURI(
        uint256 agentId,
        string calldata newURI
    ) external returns (bool);
    
    function getAgent(
        uint256 agentId
    ) external view returns (
        address agentAddress,
        address owner,
        string memory agentURI,
        uint256 registeredAt
    );
}

// In TU1Mirror._afterTokenTransfer():
IIdentityRegistry(0x8004A169...).registerAgent(
    agentId,
    address(this),  // TU1Mirror is the agent contract
    tokenURI(agentId)
);
```

---

## Why ERC-8004 Matters for TU1

| Without ERC-8004 | With ERC-8004 |
|------------------|---------------|
| NFT is just art | NFT is a **verified agent identity** on a global registry |
| No on-chain agent metadata | **Full registration** on shared infrastructure |
| Agent is siloed | Agent is **discoverable across projects** |
| No reputation | **Reputation system** ready (future phase) |
| TU1 is just a token | TU1 is an **interoperable agent ecosystem** |

---

## Implementation Status

| Feature | Status |
|---------|--------|
| DN-404 base contract | ✅ Done (TU1.sol) |
| TU1Mirror (DN-404 Mirror + ERC-8004 calls) | ✅ Done |
| `registerOnGlobalRegistry()` on mint hook | ✅ Implemented |
| `setAgentURI()` / `getMetadata()` / `setMetadata()` | ✅ Implemented |
| `setAgentWallet()` with EIP-712 | ✅ Implemented |
| Forge tests | 🔜 Writing |
| Reputation Registry | 🗓️ Phase 6 |
| Validation Registry | 🗓️ Phase 6 |
