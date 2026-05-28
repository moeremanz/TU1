# 08 — Agent Architecture 🤖

> *How the Hermes AI agent powers the TU1 ecosystem.*
> *Riddle generation, signature minting, treasury management, and daily briefings.*

---

## Overview

TU1 is powered by **Hermes Agent** — an AI agent framework running on the user's local machine (WSL/Linux). The agent handles:

| Role | Description |
|------|-------------|
| **🧠 Riddle Engine** | Generate riddles, verify answers, sign mint permits |
| **✍️ Signing Key** | ECDSA keypair (secp256k1) — signs EIP-712 permits |
| **📊 Crypto Graph** | Generate daily market briefing at 07:00 WIB |
| **🏦 Treasury Manager** | AI-guided treasury operations (buyback, rewards) |
| **📱 Telegram Bot** | User interface for minting and subscription |

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                   USER'S LOCAL MACHINE (WSL)                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   HERMES AGENT                             │   │
│  │                                                           │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐  │   │
│  │  │ Riddle       │  │ Signing Key │  │ Treasury Manager │  │   │
│  │  │ Engine       │  │ (ECDSA)     │  │ (AI-guided)     │  │   │
│  │  └──────┬───────┘  └──────┬──────┘  └────────┬─────────┘  │   │
│  │         │                 │                   │            │   │
│  │  ┌──────┴─────────────────┴───────────────────┴─────────┐ │   │
│  │  │              Cron Jobs                               │ │   │
│  │  │  ├── daily-crypto-briefing (07:00 WIB)              │ │   │
│  │  │  └── treasury-ops (hourly, if active)               │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 TELEGRAM INTEGRATION                       │   │
│  │  ┌────────────────┐  ┌────────────────┐                  │   │
│  │  │ DM from users  │  │ Home Channel  │                  │   │
│  │  │ (riddle, mint) │  │ (briefings)   │                  │   │
│  │  └────────────────┘  └────────────────┘                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 ON-CHAIN ACTIONS                           │   │
│  │  ├── Agent signs permits (off-chain)                     │   │
│  │  ├── User executes submitMint (pays gas)                 │   │
│  │  └── Treasury releases (owner executes)                  │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Agent Setup

### Requirements

| Component | Detail |
|-----------|--------|
| **Agent Framework** | Hermes Agent (hermes-agent.nousresearch.com) |
| **Runtime** | Linux / WSL |
| **Model** | DeepSeek Reasoner (via custom provider) |
| **Signing Key** | ECDSA secp256k1 private key (stored in agent env) |
| **Platform** | Telegram (connected via Hermes) |

### Configuration

The agent runs with the following Hermes CLI configuration:

```yaml
# hermes config
model: deepseek/deepseek-reasoner
provider: custom
telegram:
  enabled: true
  home_channel: "Home"  # Channel ID
skills:
  - daily-crypto-briefing
  - market-sentiment
  - crypto-market-environment
```

---

## Signing Key Management

The signing key is the **most critical security component** of TU1. It authorizes all mints.

### Key Setup

```bash
# Generate a new ECDSA key for mint signing
openssl ecparam -name secp256k1 -genkey -noout -out agent-signing-key.pem

# Extract the address for the contract
openssl ec -in agent-signing-key.pem -pubout -outform DER | \
  tail -c 65 | xxd -p -c 65 | \
  python3 -c "import sys; from eth_utils import keccak; key=bytes.fromhex(sys.stdin.read()); print('0x'+keccak(key)[12:].hex())"
```

### Key Storage

| Storage | Detail |
|---------|--------|
| **Environment Variable** | `TU1_SIGNING_KEY=0x...` |
| **Access** | Only within Hermes agent process |
| **Backup** | Encrypted backup (user-controlled) |
| **Rotation** | Via `setSigner(newAddress)` in TU1 contract — owner updates agent address |

### Security Principles

```
┌──────────────────────────────────────────────────────────────────┐
│                    KEY SECURITY LAYERS                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  L1: Physical access to machine                                  │
│    ├── User's WSL environment                                     │
│    └── Password / SSH key protected                              │
│                                                                   │
│  L2: Environment isolation                                       │
│    ├── Signing key ONLY in Hermes env                            │
│    └── NOT in source code, NOT in config files                   │
│                                                                   │
│  L3: Contract-level limits                                       │
│    ├── Max 10 mints per wallet                                   │
│    ├── 3-day mint window                                         │
│    └── Max 5,500 total mints                                     │
│                                                                   │
│  L4: Rotation capability                                         │
│    └── Owner can revoke + replace key at any time               │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Riddle Engine

### Flow

```
User: "I want to mint"
  │
  ▼
Agent: Generate riddle
  ├── Select from template pool OR
  └── Generate unique riddle (AI)
  │
  ▼
Agent: Hash the answer → riddleHash = keccak256(answer)
  │
  ▼
Agent: Send riddle to user
  │
  ▼
User: Submit answer
  │
  ▼
Agent: Verify answer
  ├── keccak256(userAnswer) == riddleHash? 
  ├── YES → Create mint permit + sign
  └── NO  → "Wrong answer, try again"
  │
  ▼
Agent: Send signature + permit to user
```

### Riddle Templates

| Type | Example |
|------|---------|
| **Crypto** | "What consensus mechanism does Ethereum use?" → `proof-of-stake` |
| **TU1-specific** | "What is the minimum TU1 to get an NFT?" → `100000` |
| **Logic** | "A wallet has 150K TU1. How many NFTs does it hold?" → `1` |
| **Security** | "What standard are TU1 agent identities registered on?" → `erc-8004` |

### Riddle Rules

| Rule | Detail |
|------|--------|
| **Case-insensitive** | Answers are lowercased before hashing |
| **No reuse** | Each riddleHash can only be used once |
| **Expiry** | Signature expires in 1 hour |
| **Difficulty** | Medium — not too easy, not too hard |

---

## Cron Jobs

### Daily Crypto Briefing (07:00 WIB)

```yaml
id: daily-briefing
name: "TU1 Crypto Graph — Daily Briefing"
schedule: "0 7 * * *"
deliver: "telegram"  # → Home Channel
skills:
  - daily-crypto-briefing
  - market-sentiment
  - crypto-market-environment
prompt: |
  Generate the daily TU1 Crypto Graph briefing.
  Format: scannable with box borders (╔═╗).
  Content:
  1. Trending narratives
  2. Market overview (BTC/ETH dominance, total cap)
  3. Top movers
  4. Key levels
  5. Notable news
```

### Treasury Operations (Future)

```yaml
id: treasury-ops
name: "TU1 Treasury Manager"
schedule: "0 * * * *"  # Every hour
skills:
  - binance
  - gmgn-swap
prompt: |
  Check treasury balance.
  If TU1 price < certain threshold, consider buyback.
  Execute only if conditions met.
```

---

## Mint Interaction (Telegram)

### User Commands

```text
/mint              → Start mint flow, get a riddle
/subscribe         → Subscribe to Crypto Graph
/unsubscribe       → Cancel subscription
/status            → Check your TU1 balance, NFTs held
/help              → List all commands
```

### Mint Dialog Example

```
User: /mint

Agent: 🤖 TU1 Mint — Solve this riddle:
       "What standard makes TU1 NFTs also AI agent identities?"
       Answer in lowercase.

User: erc-8004

Agent: ✅ Correct!
       Your mint permit is ready:
       ┌────────────────────────────────────┐
       │   Amount:  5 mints (500,000 TU1)   │
       │   Fee:     $5.00                   │
       │   Expiry:  1 hour                  │
       │                                    │
       │   submitMint(5, 0xabc..., 0xdef...)│
       └────────────────────────────────────┘
       Execute on Base: [Block Explorer Link]
       Gas cost: ~$0.0015

User: [executes transaction on block explorer]

Agent: ✅ Minted! You now have 500,000 TU1 = 5 NFTs
       Your agent identities registered on ERC-8004!
       ┌──────────────────────────────┐
       │ 🖼️ TU1 Agent #42            │
       │ 🖼️ TU1 Agent #43            │
       │ 🖼️ TU1 Agent #44            │
       │ 🖼️ TU1 Agent #45            │
       │ 🖼️ TU1 Agent #46            │
       └──────────────────────────────┘
```

---

## Treasury Management

### AI-Guided Decisions

The agent uses on-chain data + market conditions to guide treasury operations:

| Operation | Trigger | Agent Action |
|-----------|---------|-------------|
| **Buyback** | TU1 price < 50% of mint price | Suggest buyback amount |
| **LP Add** | Low liquidity depth | Suggest LP addition |
| **Rewards** | Monthly cycle | Distribute community rewards |
| **Reinvest** | Treasury > threshold | Allocate to agent development |

> **Note:** All treasury actions require **owner transaction signing** — the agent only recommends, not executes.

---

## Security & Risk

| Risk | Mitigation |
|------|------------|
| **Signing key compromised** | Contract `setSigner()` rotates key; max 10 mints/wallet limits damage |
| **Agent offline** | Mint window is 3 days — agent can be restarted anytime |
| **Riddle brute force** | 1-hour expiry, single-use riddles |
| **Key lost** | Owner can deploy new contract with new key |
| **Telegram spam** | Rate limiting on `/mint` command |
