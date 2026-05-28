# TU1 🐊

> *The first DN-404 token with ERC-8004 Trustless Agent Identity on Base.*

TU1 is a hybrid ERC-20 / ERC-721 token where **every 100,000 TU1 is an NFT** — and **every NFT is an AI agent identity** registered on-chain via ERC-8004.

---

## Key Innovations

| Innovation | Description |
|------------|-------------|
| **DN-404** | Every 100K TU1 = 1 NFT. Buy on DEX, get NFTs automatically. Sell, and NFTs burn proportionally. |
| **ERC-8004 Agent Identity** | Each NFT is a registered agent with on-chain metadata, reputation, and validation hooks. |
| **Signature Mint** | An AI agent verifies riddle answers off-chain, signs a permit, and users execute the mint themselves — scalable, trustless, no bottleneck. |
| **Subscription Burn** | TU1 Crypto Graph — daily AI market briefing. Pay with TU1 → 90% burned, 10% to treasury. |
| **V4 Hook Dynamic Fee** | Uniswap V4 Hook adjusts fees based on volume: 1% (low volume) or 1.5% (high volume), with automatic split to LP, treasury, and owner. |
| **Agentic Treasury** | Treasury managed by an AI agent for buybacks, community rewards, and ecosystem growth. |

---

## Quick Stats

| Parameter | Value |
|-----------|-------|
| **Chain** | Base (Ethereum L2) |
| **Standard** | DN-404 (ERC-20 + ERC-721 hybrid) |
| **Total Supply** | 1,000,000,000 TU1 |
| **NFT Unit** | 100,000 TU1 = 1 NFT |
| **Max NFTs** | 5,500 (from mint) |
| **Max Mints per Wallet** | 10 |
| **Mint Price** | $1 |
| **Mint Period** | 3 days or sold out |

---

## How It Works

### For Minters

```
1. Solve a riddle from the TU1 agent
2. Agent signs a mint permit
3. Execute the mint — pay gas, get TU1 + NFT instantly
```

### For Traders

```
TU1 trades like a normal ERC-20 on Uniswap V4.
Hold 100K TU1? An NFT auto-appears in your wallet.
Sell 50K TU1? The NFT burns, you keep the tokens.
```

### For NFT Holders

```
Your NFT is more than art — it's an ERC-8004 agent identity.
├── on-chain metadata (name, endpoints, reputation)
├── agentWallet for payments
└── validation hooks for trust
```

---

## Tokenomics

| Allocation | % | Detail |
|------------|---|--------|
| **Mint** | 55% | 550M TU1 — riddle-based mint, 3 days |
| **LP** | 25% | 250M TU1 — locked 12 months |
| **Treasury** | 10% | 100M TU1 — agentic wallet, post-mint |
| **Owner** | 3% | 30M TU1 — unlocked at TGE |
| **Team Vesting** | 7% | 70M TU1 — 3mo cliff + 3mo linear |

---

## Smart Contracts

| Contract | Description |
|----------|-------------|
| **TU1.sol** | DN-404 base — ERC-20 logic, signature mint, treasury release |
| **TU1Mirror.sol** *(WIP)* | DN-404 mirror + ERC-8004 Identity Registry |
| **TeamVesting.sol** | 3mo cliff + 3mo linear vesting |
| **FeeSplitter.sol** | Bankr creator share split (70.76% owner / 29.24% treasury) |
| **TU1Hook.sol** *(pending V4 deps)* | Uniswap V4 dynamic fee hook |

---

## TU1 Crypto Graph

A subscription-based AI market briefing delivered daily at 07:00 WIB.

| Detail | Value |
|--------|-------|
| **Price** | $0.50 USD / month (dynamic TU1 amount) |
| **Launch Week** | $0.30 USD / month |
| **Burn** | 90% of subscription → 🔥 burned |
| **Treasury** | 10% → 🏦 agent development |

---

## Roadmap

```
Phase 0-1: Tokenomics + Smart Contracts  ✅ Done
Phase 2: TU1Mirror (DN-404 + ERC-8004)  🟡 In progress
Phase 3: Mint Launch + DEX Listing       📅 3-day mint
Phase 4: V4 Hook Live                    📅 Post-mint
Phase 5: TU1 Crypto Graph                📅 Month 1-2
Phase 6: Community Rewards               📅 Month 1+
```

---

## Links

- **GitHub:** [moeremanz/TU1](https://github.com/moeremanz/TU1)
- **Website:** *(coming soon)*
- **X / Twitter:** *(coming soon)*
- **Contract:** *(coming soon)*

---

*Built with Hermes Agent 🤖 on Base ⛓️*
