# TU1 🐊

> *The first DN-404 token with ERC-8004 Trustless Agent Identity on Base.*
> *Every 100,000 TU1 = 1 NFT = 1 AI agent identity.*

TU1 is a hybrid ERC-20 / ERC-721 token where **every TU1 position of 100K+ automatically becomes an NFT** — and **every NFT is an AI agent identity** registered on the global ERC-8004 Identity Registry on Base.

---

## Documentation

| # | Document | Description |
|---|----------|-------------|
| 01 | [System Architecture](docs/01-overview.md) | End-to-end architecture and component breakdown |
| 02 | [Tokenomics](docs/02-tokenomics.md) | Supply allocation, DN-404 dynamics, fee model |
| 03 | [Agent Identity (ERC-8004)](docs/03-agent-identity.md) | On-chain agent registration on global registry |
| 04 | [Mint Flow](docs/04-mint-flow.md) | Signature-based mint with riddles and permits |
| 05 | [Treasury & Roadmap](docs/05-treasury-roadmap.md) | Revenue model, pipeline, development timeline |
| 06 | [Liquidity Mechanism](docs/06-liquidity-mechanism.md) | Self-bootstrapping LP from mint fees |
| 07 | [TU1 Crypto Graph](docs/07-subscription.md) | Subscription-based daily market briefing |
| 08 | [Agent Architecture](docs/08-agent-architecture.md) | Hermes agent setup, signing key, cron jobs |

---

## Key Innovations

| Innovation | Description |
|------------|-------------|
| **DN-404** | Every 100K TU1 = 1 NFT. Buy on DEX, get NFTs automatically. Sell, and NFTs burn proportionally. |
| **ERC-8004 Agent Identity** | Each NFT is a registered agent with on-chain metadata, endpoints, and agentWallet on the global identity registry. |
| **Signature Mint** | An AI agent verifies riddle answers off-chain, signs a permit, and users execute the mint themselves — scalable, trustless, no bottleneck. |
| **Self-Bootstrapping LP** | Mint fees ($0.70 per mint) automatically fund DEX liquidity. No external capital needed. |
| **Subscription Burn** | TU1 Crypto Graph — daily AI market briefing. Pay with TU1 → 90% burned, 10% to treasury. |
| **V4 Hook Dynamic Fee** | Uniswap V4 Hook adjusts fees based on volume: 1% (low) or 1.5% (high), with automatic split. |
| **Agentic Treasury** | Treasury managed by an AI agent for buybacks, community rewards, and ecosystem growth. |

---

## Quick Stats

| Parameter | Value |
|-----------|-------|
| **Chain** | Base (Ethereum L2) |
| **Standard** | DN-404 (ERC-20 + ERC-721 hybrid via Vectorized/dn404) |
| **Total Supply** | 1,000,000,000 TU1 |
| **NFT Unit** | 100,000 TU1 = 1 NFT |
| **Max NFTs from Mint** | 5,500 |
| **Max Mints per Wallet** | 10 |
| **Mint Price** | $1 (2-way split: $0.30 owner, $0.70 LP) |
| **Mint Period** | 3 days or sold out |
| **LP Lock** | 12 months |
| **Team Vesting** | 3mo cliff + 3mo linear |

---

## How It Works

### For Minters

```
1. /mint on Telegram → agent gives you a riddle
2. Answer correctly → agent signs a mint permit
3. Execute submitMint() → pay gas, get TU1 + NFT
4. Your NFT auto-registers on ERC-8004 → you own an agent identity
```

### For Traders

```
TU1 trades like a normal ERC-20 on Uniswap V4.
Hold 100K TU1? An NFT auto-appears in your wallet.
Sell below 100K TU1? The NFT burns, you keep the tokens.
```

### For NFT Holders

```
Your NFT is more than art — it's an ERC-8004 agent identity.
├── on-chain metadata (name, endpoints, reputation)
├── agentWallet for payments
└── discoverable by other projects on the global registry
```

---

## Pipeline (6 Steps)

```
STEP 1: CONCEPT + DOCS       ◄── CURRENT
STEP 2: TESTNET DEPLOY       ── faucet → deploy → test → verify
STEP 3: MINT LAUNCH (3 days) ── riddles → permits → mint → ETH accumulation
STEP 4: DEX LISTING          ── Bankr pool → LP lock → V4 Hook → FeeSplitter
STEP 5: TREASURY ACTIVE      ── buyback → rewards → operations
STEP 6: CRYPTO GRAPH LIVE    ── subscriptions → burn → sustainable income
```

---

## Smart Contracts

| Contract | Description |
|----------|-------------|
| **TU1.sol** | DN-404 base — ERC-20 logic, signature mint, treasury release |
| **TU1Mirror.sol** | DN-404 mirror + ERC-8004 Identity Registry integration |
| **TeamVesting.sol** | 3mo cliff + 3mo linear vesting |
| **FeeSplitter.sol** | Bankr creator share split (70.76% owner / 29.24% treasury) |
| **TU1Hook.sol** *(pending V4 deps)* | Uniswap V4 dynamic fee hook |

### ERC-8004 Registry

| Network | Address |
|---------|---------|
| **Base Mainnet** | `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` |
| **Base Sepolia** | `0x8004A816BFB912233c491671b3d84c89A494BD9e` |

---

## Tokenomics Summary

| Allocation | Amount | % |
|------------|--------|---|
| **Mint** | 550,000,000 TU1 | 55% |
| **LP** | 250,000,000 TU1 | 25% |
| **Treasury** | 100,000,000 TU1 | 10% |
| **Team** | 100,000,000 TU1 | 10% |
| **TOTAL** | 1,000,000,000 TU1 | 100% |

> **LP is self-funded.** Mint fees ($0.70 per mint) accumulate ETH — paired with 250M TU1 → DEX pool. No external capital.

---

## Links

- **GitHub:** [moeremanz/TU1](https://github.com/moeremanz/TU1)
- **Website:** *(coming soon)*
- **X / Twitter:** *(coming soon)*
- **Contract:** *(coming soon)*

---

*Built with [Hermes Agent](https://hermes-agent.nousresearch.com) 🤖 on Base ⛓️*
