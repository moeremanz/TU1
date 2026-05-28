# Phase 0: Tokenomics & Parameters 🔴

> *The foundation — define every number before writing a single line of code.*
>
> *Last updated: May 28, 2026*

---

## 1. Token Parameters

| Parameter | Value |
|-----------|-------|
| **Token Name** | TU1 |
| **Symbol** | TU1 |
| **Network** | Base (Ethereum L2) |
| **Total Supply** | 1,000,000,000 (1B) |
| **Decimals** | 18 |
| **Standard** | ERC-20 |

---

## 2. Supply Allocation

| Allocation | Amount | % |
|------------|--------|---|
| **Mint** | 550,000,000 | 55% |
| **LP** | 250,000,000 | 25% |
| **Treasury** | 100,000,000 | 10% |
| **Team** | 100,000,000 | 10% |
| **TOTAL** | 1,000,000,000 | 100% ✓ |

### 2.1 Team 10% — Detailed Split

| Sub-Allocation | Amount | % of Total | Vesting |
|----------------|--------|------------|---------|
| 👑 **Owner Allocation** | 30,000,000 TU1 | 3% | Unlocked at TGE |
| 🔒 **Team Vesting** | 70,000,000 TU1 | 7% | 🔴 3-month cliff → 🟢 3-month linear vest |

**Owner Allocation (30M TU1):**
- Sent directly to owner wallet at contract deployment
- Fully unlocked
- Intended for: exchange listings, partnerships, team expansion

**Team Vesting Wallet (70M TU1):**
- Locked in a dedicated vesting smart contract
- Reserved for: developers, advisors, operational contributors
- Internal distribution managed by the owner off-chain

---

## 3. Mint Mechanism

| Parameter | Value |
|-----------|-------|
| **Mint Price** | $1 |
| **Tokens per Mint** | 100,000 TU1 |
| **Max Mints per Wallet** | 10 |
| **Total Mints Available** | 5,500 |
| **Total Mint Supply** | 550,000,000 TU1 |
| **Mint Period** | 3 days or until sold out (whichever comes first) |

### 3.1 Fee per Mint ($1)

| Destination | Amount | % | Purpose |
|-------------|--------|---|---------|
| 👑 **Owner** | $0.30 | 30% | Development, infrastructure, operations |
| 💧 **LP Pool** | $0.70 | 70% | DEX liquidity foundation |
| **TOTAL** | $1.00 | 100% ✓ | |

### 3.2 Revenue Projection (Full Mint)

```
Total Mint Revenue        = $5,500
├── 👑 Owner Revenue     = $1,650  (direct — to owner wallet)
└── 💧 LP Contribution   = $3,850  (to pool — provides trading liquidity)
```

> **Note:** LP Contribution is not revenue — it is added to the DEX pool to bootstrap initial trading liquidity.

### 3.3 Unsold Mint Supply — Burn Policy

Any TU1 tokens remaining unsold after the **3-day mint period** will be **permanently burned**. This ensures:

- Fixed, verifiable circulating supply from day one
- No dilution risk from unsold tokens entering circulation later
- Incentive to mint early — supply decreases over time

---

## 4. Lock & Vesting Schedule

### 4.1 👑 Owner Allocation — 30M TU1

| Status | Detail |
|--------|--------|
| ✅ Unlocked at TGE | Available immediately upon contract deployment |
| 🎯 **Purpose** | Exchange listings, partnerships, operational runway |

### 4.2 🔒 Team Vesting — 70M TU1

| Period | Status | Claimable |
|--------|--------|-----------|
| **Month 0 — Month 3** | 🔴 CLIFF | 0 TU1 (fully locked) |
| **Month 3 — Month 6** | 🟢 LINEAR VEST | ~777,778 TU1 per day* |
| **Month 6+** | ✅ FULLY VESTED | 70,000,000 TU1 |

*\*Block-by-block linear vesting. Claimable any time during the vesting period.*

**Vesting Curve:**
```
 100% |                             ██
      |                          ██▒▒
  75% |                       ██▒▒▒▒
      |                    ██▒▒▒▒▒▒
  50% |                 ██▒▒▒▒▒▒▒▒
      |              ██▒▒▒▒▒▒▒▒▒▒
  25% |           ██▒▒▒▒▒▒▒▒▒▒▒▒
      |        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒
   0% |  ████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
      |  └─CLIFF─┘←─── LINEAR ──→
      |  0      3                 6 months
```

### 4.3 💧 LP Lock — 250M TU1

| Status | Detail |
|--------|--------|
| 🔴 **Locked 12 months** | Cannot be withdrawn under any conditions |
| ✅ **Post-lock** | Owner can manage (extend lock / gradual withdrawal) |

---

## 5. Trading Fee Structure — Uniswap V4 Hook

### 5.1 Dynamic Fee Logic

```solidity
// Simplified pseudocode — actual V4 Hook implementation
function getFee(volume24h) {
    if (volume24h < 5_000 USD) {
        return 1.00%;     // Low volume — prioritize LP growth
    } else {
        return 1.50%;     // High volume — balanced distribution
    }
}
```

### 5.2 Low Volume Mode (< $5,000/day)

| Component | Fee % | Daily @ $5K |
|-----------|-------|-------------|
| 💧 **LP Rewards** | 0.70% | $35 |
| 🏦 **Treasury** | 0.30% | $15 |
| **Total Fee** | **1.00%** | **$50** |

> Owner receives no share in low-volume mode. Priority: bootstrap LP attractiveness for traders.

### 5.3 High Volume Mode (≥ $5,000/day)

| Component | Fee % | Daily @ $1M |
|-----------|-------|-------------|
| 💧 **LP Rewards** | 0.60% | $6,000 |
| 🏦 **Treasury (via Fee Splitter)** | 0.20% | $2,000 |
| 👑 **Owner (via Fee Splitter)** | 0.484% | $4,840 |
| 🏦 **Bankr Platform Fee** | 0.216% | $2,160 |
| **Total Fee** | **1.50%** | **$15,000** |

### 5.4 Fee Splitter Logic

Bankr charges 0.216% as a platform fee from the total 1.50%. The remaining 0.684% is the **Creator Share**, split via the Fee Splitter contract:

```
Total Swap Fee: 1.50%
├── 💧 LP Rewards:       0.600% (40.0%)
├── 🏦 Bankr Platform:   0.216% (14.4%)
└── 🎯 Creator Share:    0.684% (45.6%)  ← Fee Splitter Contract
     ├── 👑 Owner:       0.484% (70.8% of creator share)
     └── 🏦 Treasury:    0.200% (29.2% of creator share)
```

### 5.5 Revenue Scenarios

| Volume | 👑 Owner/day | 🏦 Treasury/day | 💧 LP/day |
|--------|--------------|-----------------|-----------|
| $5K | $0* | $15 | $35 |
| $50K | $242 | $100 | $350 |
| $500K | $2,420 | $1,000 | $3,500 |
| **$1M** | **$4,840** | **$2,000** | **$6,000** |
| $5M | $24,200 | $10,000 | $30,000 |
| $10M | $48,400 | $20,000 | $60,000 |

*\*Low volume mode — owner share not active*

---

## 6. Token Utility 🪙

TU1 is not just a trading token — it powers an **autonomous AI-agent ecosystem** with real, revenue-generating products.

### Core Products

| Product | Status | Detail |
|---------|--------|--------|
| 📊 **TU1 Crypto Graph** | 📅 Planned | AI-generated daily market briefing & crypto analysis — subscription-based |
| 🤖 **Agent Development** | ✅ Active | TU1 treasury funds AI agent for treasury management, market analysis, and community interaction |
| 🔮 **More TBA** | 📅 Coming | Additional utilities to be announced |

### Subscription Model — TU1 Crypto Graph

Users subscribe to access AI-generated market intelligence. Payment is made **exclusively in TU1 tokens** at a dynamic rate pegged to USD:

```
💰 User subscribes
   │
   ├── 🔥 90% → BURN (permanent supply reduction)
   └── 🏦 10% → TREASURY (sustains agent development & operations)
```

**Pricing Mechanism (Dynamic USD Peg):**

The subscription price is fixed in USD — the amount of TU1 required adjusts based on TU1's current market price:

| Period | Price (USD peg) | Discount |
|--------|-----------------|----------|
| **Launch Week (Day 1-7)** | $0.30 USD worth of TU1 | 🎉 40% off |
| **Normal (Day 8+)** | $0.50 USD worth of TU1 | — |

**Example (at hypothetical TU1 prices):**

| TU1 Market Price | Normal Price | Launch Week Price |
|-----------------|--------------|-------------------|
| $0.01 | 50 TU1 | 30 TU1 |
| $0.05 | 10 TU1 | 6 TU1 |
| $0.10 | 5 TU1 | 3 TU1 |
| $0.50 | 1 TU1 | 0.6 TU1 |

**Fee Split:**
- 🔥 **90%** of subscription value → **permanently burned**
- 🏦 **10%** → **Treasury** (funds agent development & infrastructure)

### TU1 Crypto Graph — Features

The subscription product delivers the exact same briefing the TU1 AI agent produces daily at 07:00 WIB:

```
📊 TU1 Crypto Graph — Daily Briefing

📌 Market Overview
├── Bitcoin dominance & price action
├── Top movers (gainers/losers)
└── Fear & Greed Index

🔥 Trending Narratives
├── Top 3 trending sectors/categories
└── Notable market catalysts

🐊 TU1 Ecosystem
├── TU1 price & volume analysis
├── Key on-chain metrics
└── Recent developments & announcements

📅 Today's Events
├── Upcoming catalysts & releases
└── Risk calendar
```

**Delivery:** Daily at 07:00 WIB via automated agent.

### Subscription Revenue Projections

| Subscribers | 🔥 Burn/month | 🏦 Treasury/month |
|-------------|--------------|-------------------|
| 100 | $45 | $5 |
| 500 | $225 | $25 |
| 1,000 | $450 | $50 |
| 5,000 | $2,250 | $250 |
| 10,000 | $4,500 | $500 |
| 50,000 | $22,500 | $2,500 |

*Based on $0.50 USD normal price. Actual TU1 amount varies with market price.*

### Why This Works

```
          🔥 Every subscriber = supply decreases
         ↗️
  🐊 Crypto Graph quality → more subscribers → more burn
         ↖️
          🏦 Fee feeds treasury → agent gets better
```

| Investor Lens | Impact |
|---------------|--------|
| **Real utility** | Not a memecoin — has a paying product with real value |
| **Built-in burn** | Every subscription = permanent supply reduction |
| **Dynamic pricing** | USD peg protects subscriber value, TU1-denominated burn increases with price |
| **Sustainable treasury** | 10% fee funds development without dilution |
| **Agent flywheel** | Better product → more users → more burn & fee |
| **Unique positioning** | First token with AI-agent-as-a-service subscription |

### Why Agent Utility Matters

- The treasury is managed by an AI agent, not a human multisig
- TU1 holders benefit from agent-driven market operations
- The agent itself is the product — users pay TU1 to access its intelligence
- Future utilities will expand the agent's capabilities

> *The TU1 agent is not just a gimmick — it is the core operational engine AND the revenue generator of the ecosystem.*

---

## 7. Treasury & Reinvestment Model 🏦

The treasury receives **0.20% of all swap volume** (high-volume mode). Instead of buybacks, we follow a **reinvestment model**:

### Treasury Allocation

| Allocation | % of Treasury | Purpose |
|------------|--------------|---------|
| 🎁 **Community Rewards** | 30% | Airdrops, competitions, liquidity incentives, staker rewards |
| 🤖 **Agent Development** | 40% | AI agent infrastructure, compute, upgrades |
| 📢 **Marketing & Growth** | 20% | Listings, partnerships, campaigns |
| 💼 **Operations** | 10% | Legal, audits, admin |

### Monthly Treasury Flow (at $1M daily volume)

```
Treasury Revenue: $60,000/month ($2,000/day)
├── 🎁 Community Rewards:   $18,000  → distributed back to holders
├── 🤖 Agent Development:   $24,000  → infrastructure + compute
├── 📢 Marketing:           $12,000  → growth initiatives
└── 💼 Operations:           $6,000  → overhead
```

> **No buybacks.** Treasury is reinvested into what grows the ecosystem: the agent, the community, and the brand.

---

## 8. Roadmap 🗺️

```
Phase 0: Tokenomics Finalized
    └── ✅ Complete
Phase 1: Smart Contract Development
    └── 🟡 In progress
Phase 2: Contract Audit
    └── ⏳ Third-party security audit
Phase 3: Mint Launch
    └── 📅 3-day mint period or until sold out
Phase 4: DEX Listing + V4 Hook
    └── 📅 Immediately after mint ends or sold out
Phase 5: Agent Development
    └── 📅 AI treasury agent live
Phase 6: TU1 Crypto Graph Launch
    └── 📅 Subscription product live (AI market briefing daily at 07:00 WIB)
Phase 7: Community Rewards Program
    └── 📅 30% treasury allocation begins distribution
More: TBA
```

### Milestone Triggers

| Event | Trigger | Window |
|-------|---------|--------|
| **Mint Launch** | Contract deployed + audited | Day 0 |
| **DEX Listing + V4 Hook** | Mint sold out OR 3 days elapsed | Day 3 max |
| **Agent Live** | Post-listing stability achieved | Week 2-4 |
| **TU1 Crypto Graph Launch** | Agent operational + UI ready | Month 1-2 |
| **Community Rewards** | Treasury accumulated sufficient funds | Month 1+ |

---

## 9. Final Reference — All Parameters

```
SUPPLY_TOTAL        = 1,000,000,000 TU1
SUPPLY_MINT         =   550,000,000 (55%)  → 5,500 mints × 100K
SUPPLY_LP           =   250,000,000 (25%)  → 12-month lock
SUPPLY_TREASURY     =   100,000,000 (10%)  → Agentic wallet
SUPPLY_TEAM         =   100,000,000 (10%)
  ├── OWNER         =    30,000,000 (3%)   → ✅ Unlocked at TGE
  └── VESTING       =    70,000,000 (7%)   → 🔴 3mo cliff + 🟢 3mo linear

MINT_PRICE          = $1
MINT_TOKENS         = 100,000 TU1
MAX_MINT_PER_WALLET = 10
TOTAL_MINTS         = 5,500
MINT_PERIOD         = 3 days (or sold out)
UNSOLD_MINT_BURN    = ✅ Burned after 3 days

MINT_FEE_OWNER      = $0.30 (30%) → direct
MINT_FEE_LP         = $0.70 (70%) → to pool

SWAP_FEE_LOW        = 1.00% (vol < $5K/day)
SWAP_FEE_HIGH       = 1.50% (vol ≥ $5K/day)
  LP    = 0.60%
  OWNER = 0.484%
  TRSRY = 0.200%
  BANKR = 0.216%

LP_LOCK             = 12 months
TEAM_CLIFF          = 3 months
TEAM_VEST           = 3 months linear (6 months total from deploy)

SUBSCRIPTION_PRICE  = $0.50 USD / month (dynamic TU1 amount)
SUBSCRIPTION_DISCOUNT = $0.30 USD / month (launch week only)
SUBSCRIPTION_BURN   = 90% → 🔥 Burned
SUBSCRIPTION_FEE    = 10% → Treasury

TREASURY_COMMUNITY  = 30%
TREASURY_AGENT      = 40%
TREASURY_MARKETING  = 20%
TREASURY_OPS        = 10%
```

---

## 10. Risk & Mitigation

| Risk | Prob. | Mitigation |
|------|-------|------------|
| **Bot attack on mint** | 🟡 Medium | Max 10/wallet + riddle gate (Phase 1) |
| **Liquidity rug pull** | 🟢 Low | 12-month LP lock, verified contract, open source |
| **Owner price dump** | 🟡 Medium | Only 3% of supply unlocked at TGE — limited downside |
| **Team dump post-vest** | 🟢 Low | 7% distributed via vesting — gradual release |
| **Low post-launch volume** | 🟡 Medium | Treasury-funded community rewards + agent-driven growth |
| **Smart contract bug** | 🟡 Medium | Open source + third-party audit (Phase 2) |
| **Mint not fully sold** | 🟢 Low | Remaining supply burned after 3 days — deflationary |

---

## 11. Review Checklist

- [x] Total supply: 55 + 25 + 10 + 10 = 100%
- [x] Team split: 3% owner (unlocked) + 7% vesting
- [x] Mint fee split: $0.30 owner + $0.70 LP = $1.00
- [x] Max mints: 5,500 × 100K = 550M ✓
- [x] Unsold mint burned after 3 days
- [x] LP lock: 12 months
- [x] Team cliff: 3 months
- [x] Team vest: 3 months linear (6 months total)
- [x] V4 Hook dynamic fee: 1% low, 1.5% high
- [x] Fee splitter: owner 0.484% + treasury 0.2%
- [x] Treasury split: 30% community, 40% agent, 20% marketing, 10% ops
- [x] Token utility: Agent ecosystem + TBA
- [x] Roadmap with milestones and triggers
- [x] Revenue projections calculated
- [x] Risk matrix documented

---

*Next: **Phase 1 — Smart Contracts** 🟡*
