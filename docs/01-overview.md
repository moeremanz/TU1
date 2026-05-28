# 01 — System Architecture 🏗️

> *End-to-end architecture of the TU1 ecosystem.*

---

## High-Level Diagram

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                              USER LAYER                                 │
│                                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│  │ Website  │    │  DEX     │    │ Telegram │    │   Wallet (Meta-  │  │
│  │ (mint)   │    │ (trade)  │    │ (brief)  │    │   Mask / WC)    │  │
│  └─────┬─────┘    └────┬─────┘    └────┬─────┘    └────────┬─────────┘  │
│        │               │               │                   │            │
├────────┼───────────────┼───────────────┼───────────────────┼────────────┤
│        │               │               │                   │            │
│  ┌─────▼───────────────▼───────────────▼───────────────────▼──────────┐ │
│  │                        AGENT LAYER (Hermes)                       │ │
│  │                                                                    │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────────┐  │ │
│  │  │ Agent API    │  │ Riddle       │  │ Treasury Manager       │  │ │
│  │  │ (website     │  │ Engine       │  │ (buyback, rewards,     │  │ │
│  │  │  backend)    │  │ (generate +  │  │  reinvest)             │  │ │
│  │  │              │  │  verify)     │  │                        │  │ │
│  │  └──────┬───────┘  └──────────────┘  └───────────┬─────────────┘  │ │
│  └─────────┼─────────────────────────────────────────┼────────────────┘ │
│            │                                         │                  │
├────────────┼─────────────────────────────────────────┼──────────────────┤
│            │                                         │                  │
│  ┌─────────▼─────────────────────────────────────────▼────────────────┐│
│  │                       CONTRACT LAYER                               ││
│  │                                                                    ││
│  │  ┌──────────────────────────────────────────────────────────────┐  ││
│  │  │                      TU1.sol (DN-404)                       │  ││
│  │  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐  │  ││
│  │  │  │ ERC-20      │  │ Signature    │  │ Treasury Release   │  │  ││
│  │  │  │ (trading,   │  │ Mint         │  │ (post-mint →       │  │  ││
│  │  │  │  transfers) │  │ (submitMint) │  │  agentic wallet)   │  │  ││
│  │  │  └─────────────┘  └──────────────┘  └────────────────────┘  │  ││
│  │  └──────────────────────────────────────────────────────────────┘  ││
│  │                                                                    ││
│  │  ┌──────────────────────────────────────────────────────────────┐  ││
│  │  │                   TU1Mirror.sol (ERC-8004)                   │  ││
│  │  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐  │  ││
│  │  │  │ ERC-721     │  │ Agent        │  │ Reputation +       │  │  ││
│  │  │  │ (NFT: auto- │  │ Identity     │  │ Validation Hooks   │  │  ││
│  │  │  │  mint/burn) │  │ (ERC-8004)   │  │ (future)           │  │  ││
│  │  │  └─────────────┘  └──────────────┘  └────────────────────┘  │  ││
│  │  └──────────────────────────────────────────────────────────────┘  ││
│  │                                                                    ││
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ ││
│  │  │ TeamVesting  │  │ FeeSplitter  │  │ TU1Hook (V4)            │ ││
│  │  │ (3mo cliff + │  │ (owner/      │  │ (dynamic fee:            │ ││
│  │  │  3mo linear) │  │  treasury)   │  │  1% / 1.5%)             │ ││
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘ ││
│  └────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### 1. User Layer

| Component | Purpose | Tech |
|-----------|---------|------|
| **Website** | Mint UI, wallet connect, riddle display, payment | HTML/JS, ethers.js, WalletConnect |
| **DEX** | TU1 trading | Uniswap V4 |
| **Telegram** | Daily briefings, subscription management | Telegram API |
| **Wallet** | Execute transactions | MetaMask, WalletConnect |

### 2. Agent Layer (Hermes)

| Component | Purpose |
|-----------|---------|
| **Agent API** | Backend API called by website — handles riddle verification + mint authorization |
| **Riddle Engine** | Generate riddles, verify answers off-chain |
| **Treasury Manager** | AI-driven treasury operations (buyback, rewards, reinvest) |
| **Crypto Graph** | Daily market briefing generation |
| **Subscription Manager** | Handle subscriptions via Telegram |

### 3. Contract Layer

| Contract | Role | Key Functions |
|----------|------|---------------|
| **TU1.sol** | DN-404 base (ERC-20 + NFT state) | `submitMint()`, `openMint()`, `releaseTreasury()`, `burn()` |
| **TU1Mirror.sol** | DN-404 mirror + ERC-8004 | `tokenURI()`, `setAgentURI()`, `getMetadata()` |
| **TeamVesting.sol** | Team token vesting | `addBeneficiary()`, `claim()`, `claimableAmount()` |
| **FeeSplitter.sol** | Bankr creator share split | `distributeETH()`, `distributeERC20()` |
| **TU1Hook.sol** | V4 dynamic fee hook | `getFee()`, `beforeSwap()` |

---

## Data Flow: Mint

```
🧑 User                    🌐 Website                  🤖 Agent API            ⛓️ Contract
   │                         │                            │                       │
   │── Connect Wallet ──────→│                            │                       │
   │── Click "Mint" ────────→│                            │                       │
   │                         │── Request riddle ────────→│                       │
   │                         │←───── Riddle ────────────│                       │
   │←── Riddle shown ───────│                            │                       │
   │── Submit answer ───────→│                            │                       │
   │                         │── Verify answer ─────────→│                       │
   │                         │←──── ✅ Correct ─────────│                       │
   │←── Payment prompt ─────│                            │                       │
   │── Approve $1 ETH ──────→│ (WalletConnect popup)     │                       │
   │                         │── Payment received ───────│                       │
   │                         │── Request mint ──────────→│── mint(user, amt) ──→│
   │                         │                            │                       │
   │                         │                            │        Verify ✅     │
   │                         │                            │        Mint TU1      │
   │                         │                            │        Auto-mint NFT │
   │                         │                            │        Register ERC-8004│
   │                         │                            │                       │
   │←── "Minted! X TU1" ───│←──────── Success ──────────│←───── ✅ Minted ─────│
```

### Flow Steps

| Step | Actor | Action |
|------|-------|--------|
| 1 | User | Connects wallet (MetaMask / WalletConnect) on website |
| 2 | User | Clicks "Mint" — website shows a riddle |
| 3 | Website | Fetches riddle from Agent API |
| 4 | User | Types answer and submits |
| 5 | Website | Sends answer to Agent API for verification |
| 6 | Agent API | Verifies answer + checks eligibility (max 10, not reused) |
| 7 | Website | Shows payment prompt ($1 ETH) |
| 8 | User | Approves payment via WalletConnect |
| 9 | Website | Forwards ETH + calls Agent API to authorize mint |
| 10 | Agent API | Calls `submitMint()` on contract with signature |
| 11 | Contract | Verifies signature → mints TU1 → mints NFT → registers on ERC-8004 |
| 12 | Website | Shows success + TU1 balance + NFT preview |

---

## DN-404 NFT Dynamics

```
Balance: 0 TU1          → No NFT
Balance: 50,000 TU1     → No NFT (below unit)
Balance: 100,000 TU1    → 1 NFT 🖼️
Balance: 250,000 TU1    → 2 NFTs 🖼️🖼️
Balance: 1,000,000 TU1  → 10 NFTs

Sell 150,000 TU1:
   Balance: 100,000 TU1 → 1 NFT 🖼️ (2 burned)

Buy 50,000 TU1:
   Balance: 150,000 TU1 → 1 NFT 🖼️ (same NFT, +50K tokens)
```

---

## ERC-8004 Agent Identity

Each NFT is also an ERC-8004 Identity Registry entry:

```json
{
  "agentId": 1,
  "name": "TU1 Agent #1",
  "description": "TU1 agent identity — solves riddles, earns rewards",
  "image": "ipfs://...",
  "endpoints": [
    { "type": "a2a", "url": "https://agent.tu1.io/a2a", "version": "1.0" }
  ],
  "agentWallet": "0x..."
}
```
