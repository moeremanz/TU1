# 01 — System Architecture 🏗️

> *End-to-end architecture of the TU1 ecosystem.*

---

## High-Level Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              USER LAYER                                 │
│                                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│  │ Telegram  │    │ Website  │    │  DEX     │    │   Wallet (Meta-  │  │
│  │ (riddle)  │    │ (mint)   │    │ (trade)  │    │   Mask / WC)    │  │
│  └─────┬─────┘    └────┬─────┘    └────┬─────┘    └────────┬─────────┘  │
│        │               │               │                   │            │
├────────┼───────────────┼───────────────┼───────────────────┼────────────┤
│        │               │               │                   │            │
│  ┌─────▼───────────────▼───────────────▼───────────────────▼──────────┐ │
│  │                        AGENT LAYER (Hermes)                       │ │
│  │                                                                    │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────────┐  │ │
│  │  │ Riddle Engine │  │ Signing Key  │  │ Treasury Manager       │  │ │
│  │  │ (generate +   │  │ (ECDSA sign  │  │ (buyback, rewards,     │  │ │
│  │  │  verify)      │  │  mint permit)│  │  reinvest)             │  │ │
│  │  └──────┬───────┘  └──────┬───────┘  └───────────┬─────────────┘  │ │
│  └─────────┼─────────────────┼───────────────────────┼────────────────┘ │
│            │                 │                       │                  │
├────────────┼─────────────────┼───────────────────────┼──────────────────┤
│            │                 │                       │                  │
│  ┌─────────▼─────────────────▼───────────────────────▼────────────────┐│
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
| **Telegram** | Riddle interaction with agent | Telegram API |
| **Website** | Mint UI, wallet connect | HTML/JS, ethers.js |
| **DEX** | TU1 trading | Uniswap V4 |
| **Wallet** | Execute transactions | MetaMask, WalletConnect |

### 2. Agent Layer (Hermes)

| Component | Purpose |
|-----------|---------|
| **Riddle Engine** | Generate riddles, verify answers off-chain |
| **Signing Key** | ECDSA sign mint permits (EIP-712) |
| **Treasury Manager** | AI-driven treasury operations (buyback, rewards, reinvest) |
| **Crypto Graph** | Daily market briefing generation |

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
User                     Agent                  Contract
 │                        │                        │
 │  1. Request riddle ───→│                        │
 │                        │                        │
 │  2. Generate riddle    │                        │
 │←────── Riddle ────────│                        │
 │                        │                        │
 │  3. Submit answer ────→│                        │
 │                        │                        │
 │  4. Verify answer      │                        │
 │  5. Sign permit        │                        │
 │←── Signature + hash ──│                        │
 │                        │                        │
 │  6. submitMint(        │                        │
 │       amount,          │                        │
 │       riddleHash,      │                        │
 │       deadline,        │                        │
 │       signature        │                        │
 │     ) ────────────────────────────────────────→ │
 │                        │                        │
 │                        │     7. Verify sig ✅   │
 │                        │     8. Check max 10 ✅ │
 │                        │     9. Mint TU1 + NFT  │
 │                        │                        │
 │←────── TU1 + NFT ─────│────────────────────────│
```

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
