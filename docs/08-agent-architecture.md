# 08 — Agent Architecture 🤖

> *How the Hermes AI agent powers the TU1 ecosystem.*
> *Riddle generation, signature minting, treasury management, and daily briefings.*

---

## Overview

TU1 is powered by **Hermes Agent** — an AI agent framework running on the user's local machine (WSL/Linux). The agent handles:

| Role | Description |
|------|-------------|
| **🧠 Agent API** | Backend API for the website — riddle generation, answer verification, mint signing |
| **✍️ Signing Key** | ECDSA keypair (secp256k1) — signs EIP-712 mint permits |
| **📊 Crypto Graph** | Generate daily market briefing |
| **🏦 Treasury Manager** | AI-guided treasury operations (buyback, rewards) |
| **📱 Subscription Manager** | Handle subscriptions + briefings via Telegram |

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                   USER'S LOCAL MACHINE (WSL)                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   HERMES AGENT                             │   │
│  │                                                           │   │
│  │  ┌─────────────────┐  ┌─────────────┐  ┌──────────────┐  │   │
│  │  │ Agent API       │  │ Crypto      │  │ Treasury     │  │   │
│  │  │ (riddles,       │  │ Graph       │  │ Manager      │  │   │
│  │  │  verify, sign)  │  │ (briefings) │  │ (AI-guided)  │  │   │
│  │  └────────┬────────┘  └──────┬──────┘  └──────┬───────┘  │   │
│  │           │                  │                 │          │   │
│  │  ┌────────┴──────────────────┴─────────────────┴────────┐ │   │
│  │  │              Cron Jobs                               │ │   │
│  │  │  ├── daily-crypto-briefing                           │ │   │
│  │  │  └── treasury-ops (hourly, if active)               │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 EXTERNAL INTERFACES                        │   │
│  │  ┌────────────────┐  ┌────────────────┐                  │   │
│  │  │ Website calls  │  │ Telegram       │                  │   │
│  │  │ Agent API      │  │ (briefings,    │                  │   │
│  │  │ (riddle+mint)  │  │  subscriptions)│                  │   │
│  │  └────────────────┘  └────────────────┘                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 ON-CHAIN ACTIONS                           │   │
│  │  ├── Website calls submitMint() via Agent signature       │   │
│  │  ├── User approves $1 ETH via WalletConnect              │   │
│  │  ├── Contract auto-mints NFT + registers ERC-8004        │   │
│  │  └── Treasury releases (owner executes)                  │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘

                        ┌──────────────────┐
                        │   🌐 WEBSITE     │
                        │   (User-facing)  │
                        │                  │
                        │  - WalletConnect │
                        │  - Riddle UI     │
                        │  - Payment UI    │
                        │  - Calls Agent   │
                        │    API           │
                        └────────┬─────────┘
                                 │
                                 │ HTTP/JSON
                                 │
                        ┌────────▼─────────┐
                        │   Agent API       │
                        │   GET /riddle     │
                        │   POST /verify    │
                        │   POST /mint      │
                        └──────────────────┘
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

The riddle engine powers the Agent API's `/riddle` and `/verify` endpoints.

### Flow

```
Website requests riddle (GET /api/riddle)
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
Agent: Return {riddle, sessionId, riddleHash, expiresAt} to website
  │
  ▼
Website shows riddle → User submits answer
  │
  ▼
Website POST /api/verify {sessionId, answer, wallet, amount}
  │
  ▼
Agent: Verify answer
  ├── keccak256(userAnswer) == riddleHash? 
  ├── YES → Check eligibility + sign EIP-712 permit
  └── NO  → Return {"status": "rejected"}
  │
  ▼
Agent: Return {signature, to, amount, riddleHash, deadline} to website
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

### Daily Crypto Briefing

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

## Agent API Endpoints

The website communicates with the agent via a REST API. The agent exposes these endpoints:

### `GET /api/riddle`

```
Request:
  GET /api/riddle?wallet=0x...

Response (200):
{
  "sessionId": "abc123",
  "riddle": "What standard makes TU1 NFTs agent identities?",
  "riddleHash": "0xdef456...",
  "expiresAt": 1716900000
}
```

Generates a unique riddle and stores the hashed answer. Session expires in 1 hour.

### `POST /api/verify`

```
Request:
{
  "sessionId": "abc123",
  "answer": "erc-8004",
  "wallet": "0x...",
  "amount": 5
}

Response (200 - correct):
{
  "status": "verified",
  "signature": "0xabc...",
  "to": "0x...",
  "amount": 5,
  "riddleHash": "0xdef...",
  "deadline": 1716900000
}

Response (403 - wrong):
{
  "status": "rejected",
  "reason": "Wrong answer"
}
```

Verifies the answer against the stored hash. If correct → checks eligibility (max 10, not reused) → signs EIP-712 permit.

### `POST /api/mint`

```
Request:
{
  "sessionId": "abc123",
  "signature": "0xabc...",
  "amount": 5,
  "txHash": "0x..."  // payment confirmation
}

Response (200):
{
  "status": "minted",
  "amount": 5,
  "tokenId": 42,
  "txHash": "0x..."
}
```

Called after user pays. Agent calls `submitMint()` on contract.

---

## Telegram (Subscription + Briefings)

Telegram handles **subscriptions and daily briefings only** — minting is via the website.

### Telegram Commands

```text
/subscribe         → Subscribe to TU1 Crypto Graph
/unsubscribe       → Cancel subscription
/status            → Check subscription status
/help              → List all commands
```

### Daily Briefing Delivery

```
Cron triggers
    │
    ▼
Agent generates briefing
    │
    ▼
Delivers to all active subscribers via Telegram DM
    │
    ▼
Also posts to Home Channel (public preview)
```

### Subscription Dialog

```
User: /subscribe

Agent: 📊 TU1 Crypto Graph — $0.50/month
       ┌────────────────────────────────────┐
       │  Daily AI market briefing at       │
       │  on Telegram                         │
       │                                    │
       │  90% of TU1 → 🔥 burned            │
       │  10% → 🏦 treasury                 │
       │                                    │
       │  Launch week: $0.30/month          │
       └────────────────────────────────────┘
       Send 50 TU1 to 0x... to subscribe.

User: [sends TU1 to subscription contract]

Agent: ✅ Subscribed! Your first briefing arrives tomorrow.
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
| **Telegram spam** | Rate limiting on subscription commands |
