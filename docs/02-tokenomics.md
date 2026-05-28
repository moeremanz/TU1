# 02 — Tokenomics 🪙

> *TU1 tokenomics with DN-404 dynamics.*

---

## Supply Allocation

| Allocation | Amount | % |
|------------|--------|---|
| **Mint** | 550,000,000 TU1 | 55% |
| **LP** | 250,000,000 TU1 | 25% |
| **Treasury** | 100,000,000 TU1 | 10% |
| **Team** | 100,000,000 TU1 | 10% |
| **TOTAL** | 1,000,000,000 TU1 | 100% |

---

## DN-404 Dynamics

### Unit

```
1 NFT = 100,000 TU1
```

| TU1 Balance | NFTs Held |
|-------------|-----------|
| 0 — 99,999 | 0 |
| 100,000 — 199,999 | 1 |
| 200,000 — 299,999 | 2 |
| ... | ... |
| 1,000,000 | 10 |

### Auto-Mint & Burn

| Action | NFT Effect |
|--------|------------|
| Buy 100K+ TU1 on DEX | New NFT auto-mints to wallet |
| Sell TU1 below unit threshold | NFT auto-burns |
| Transfer 100K TU1 | NFT auto-transfers with tokens |
| Receive 100K TU1 as payment | NFT auto-mints |

> Users can opt-out of automatic NFT minting via `setSkipNFT(true)`.

---

## Mint Mechanism

| Parameter | Value |
|-----------|-------|
| **Mint Price** | $1 |
| **Tokens per Mint** | 100,000 TU1 |
| **NFTs per Mint** | 1 (auto via DN-404) |
| **Max Mints per Wallet** | 10 |
| **Total Mints Available** | 5,500 |
| **Max NFTs from Mint** | 5,500 |
| **Mint Period** | 3 days or until sold out |

### Mint Fee Split ($1)

| Destination | Amount | Purpose |
|-------------|--------|---------|
| **Owner** | $0.30 | Development, infrastructure |
| **LP Pool** | $0.70 | DEX liquidity foundation |

### Unsold Mint — Burn

Any TU1 remaining unsold after the 3-day mint period is **permanently burned**.

---

## Lock & Vesting

### LP Lock — 250M TU1

| Status | Detail |
|--------|--------|
| 🔴 Locked 12 months | Cannot be withdrawn |
| ✅ Post-lock | Owner can manage |

### Team Vesting — 70M TU1

| Period | Status | Claimable |
|--------|--------|-----------|
| Month 0-3 | 🔴 CLIFF | 0% |
| Month 3-6 | 🟢 LINEAR VEST | ~777,778 TU1/day |
| Month 6+ | ✅ FULLY VESTED | 100% |

### Owner Allocation — 30M TU1

| Status | Detail |
|--------|--------|
| ✅ Unlocked at TGE | Available upon deployment |
| **Purpose** | Exchange listings, partnerships, operations |

---

## Trading Fee — Uniswap V4 Hook

### Low Volume (< $5K/day): 1.00%

| Recipient | % of Volume |
|-----------|-------------|
| 💧 LP Rewards | 0.70% |
| 🏦 Treasury | 0.30% |

### High Volume (≥ $5K/day): 1.50%

| Recipient | % of Volume |
|-----------|-------------|
| 💧 LP Rewards | 0.60% |
| 👑 Owner (via Fee Splitter) | 0.484% |
| 🏦 Treasury (via Fee Splitter) | 0.200% |
| 🏦 Bankr Platform Fee | 0.216% |

### Fee Splitter Logic

```
Total Swap Fee: 1.50%
├── LP Rewards:       0.600% (40.0%)
├── Bankr Platform:   0.216% (14.4%)
└── Creator Share:    0.684% (45.6%)
     ├── Owner:       0.484% (70.8%)
     └── Treasury:    0.200% (29.2%)
```

---

## Treasury & Reinvestment

The treasury receives **0.20% of all swap volume** + **10% of TU1 Crypto Graph subscription fees**.

| Allocation | % of Treasury | Purpose |
|------------|--------------|---------|
| 🎁 Community Rewards | 30% | Airdrops, incentives, staker rewards |
| 🤖 Agent Development | 40% | AI infrastructure, compute, upgrades |
| 📢 Marketing & Growth | 20% | Listings, partnerships, campaigns |
| 💼 Operations | 10% | Legal, audits, admin |

---

## TU1 Crypto Graph — Subscription Model

| Parameter | Value |
|-----------|-------|
| **Product** | AI-generated daily market briefing |
| **Normal Price** | $0.50 USD/month (dynamic TU1 amount) |
| **Launch Week** | $0.30 USD/month |
| **Burn** | 90% of subscription → 🔥 permanently burned |
| **Treasury Fee** | 10% → agent development & infrastructure |
| **Delivery** | Daily at 07:00 WIB |

### Subscription Scenarios

| Subscribers | 🔥 Burn/month | 🏦 Treasury/month |
|-------------|--------------|-------------------|
| 100 | $45 | $5 |
| 1,000 | $450 | $50 |
| 10,000 | $4,500 | $500 |
| 50,000 | $22,500 | $2,500 |

---

## Wallet Architecture

```
DEPLOY (tx.origin = deployer wallet)
│
├── 250M LP       → 🔵 DEPLOYER WALLET (for Bankr setup)
├── 30M Owner     → 👑 OWNER WALLET (unlocked)
├── 70M Vesting   → 🔒 VESTING CONTRACT (team vesting)
├── 100M Treasury → 🤖 AGENTIC WALLET (post-mint release)
└── 550M Mint     → Contract (minted via submitMint or burned)
```

---

## Risk Matrix

| Risk | Prob. | Mitigation |
|------|-------|------------|
| Bot attack on mint | 🟡 Medium | Riddle gate + signature mint |
| Liquidity rug | 🟢 Low | 12-month LP lock, verified contract |
| Team dump | 🟢 Low | 7% vesting (cliff + linear) |
| Low post-launch volume | 🟡 Medium | Treasury-funded community rewards |
| Contract bug | 🟡 Medium | Open source + audit (agent + pro later) |
| Unsold mint | 🟢 Low | Burned after 3 days — deflationary |
