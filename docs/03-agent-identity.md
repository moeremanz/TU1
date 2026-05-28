# 03 — Agent Identity (ERC-8004) 🆔

> *Every NFT is a registered agent on-chain. Every holder owns an agent identity.*

---

## What is ERC-8004?

ERC-8004: **Trustless Agents** — a proposed Ethereum standard for discovering, choosing, and trusting AI agents on-chain. It defines three registries:

| Registry | Purpose |
|----------|---------|
| **Identity Registry** | On-chain agent registration (ERC-721 + metadata) |
| **Reputation Registry** | Feedback and scoring system |
| **Validation Registry** | Independent validator hooks |

TU1 implements the **Identity Registry** directly in the TU1Mirror contract.

---

## Architecture

```
TU1Mirror.sol
│
├── DN-404 Layer ─── ERC-721 (NFT auto-mint/burn with TU1 balance)
│
├── ERC-8004 Layer ─ Agent Identity
│   ├── agentURI → Registration file (JSON metadata)
│   ├── getMetadata / setMetadata (on-chain agent data)
│   ├── agentWallet (payment address, EIP-712 verified)
│   └── Reserved keys: agentWallet
│
└── Future Layer ── Reputation + Validation hooks
```

---

## Agent Registration

When a user mints their first 100,000 TU1, they automatically receive:

1. **An NFT** (via DN-404)
2. **An agent identity** (via ERC-8004)

The NFT's `tokenURI` resolves to an agent registration file:

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
| **Buy 100K TU1** | Mint new NFT = register new agent identity |
| **Sell TU1** | NFT burns = agent identity de-registers |
| **Transfer NFT** | Agent identity transfers to new owner |
| **Set agentURI** | Update agent metadata (owner only) |
| **Set agentWallet** | Change payment address (EIP-712 verified) |

---

## Metadata Functions

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

Sets on-chain metadata. Only callable by the NFT owner or approved operator.

**Reserved key:** `agentWallet` — cannot be set via `setMetadata()`. Must be set via `setAgentWallet()` with EIP-712 signature verification.

### Set Agent Wallet

```solidity
function setAgentWallet(uint256 agentId, address wallet, bytes calldata signature)
    external;
```

Sets the payment address for the agent. Requires an EIP-712 signature from the new wallet address to prove ownership.

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

## Future: Reputation Registry

The ERC-8004 Reputation Registry can be deployed later to add:

| Feature | How It Works |
|---------|-------------|
| **Feedback** | Users post feedback about agent interactions |
| **Scoring** | On-chain + off-chain scoring algorithms |
| **Auditor Network** | Independent validators verify agent actions |
| **Insurance Pools** | Stake against agent reputation |

```solidity
// Future interface
function addFeedback(
    uint256 agentId,
    address client,
    int256 score,
    string calldata feedbackURI,
    bytes32 feedbackHash
) external;
```

---

## Why ERC-8004 Matters for TU1

| Without ERC-8004 | With ERC-8004 |
|------------------|---------------|
| NFT is just art | NFT is a **verified agent identity** |
| No on-chain agent metadata | **Full registration file** on-chain |
| Agent is a black box | Agent is **discoverable and verifiable** |
| No reputation | **Reputation system** ready to deploy |
| TU1 is just a token | TU1 is an **agent ecosystem** |

---

## Implementation Status

| Feature | Status |
|---------|--------|
| DN-404 integration | 🔜 Implementing |
| `setAgentURI()` | 🔜 Next |
| `getMetadata()` / `setMetadata()` | 🔜 Next |
| `setAgentWallet()` with EIP-712 | 🔜 Next |
| Reputation Registry | 🗓️ Future |
| Validation Registry | 🗓️ Future |
