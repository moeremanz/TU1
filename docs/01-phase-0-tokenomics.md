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
- Fully unlocked — no lock or vesting restrictions
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
└── 💧 LP Contribution   = $3,850  (to pool — NOT revenue, provides trading liquidity)
```

> **Note:** LP Contribution is not revenue — it is added to the DEX pool to bootstrap initial trading liquidity.

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

*\*Block-by-block linear vesting. Claimable any time during the vesting period. Longer wait = larger lump sum claimable at once.*

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

## 6. Final Reference — All Parameters

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
```

---

## 7. Risk & Mitigation

| Risk | Prob. | Mitigation |
|------|-------|------------|
| **Bot attack on mint** | 🟡 Medium | Max 10/wallet + riddle gate (Phase 2) |
| **Liquidity rug pull** | 🟢 Low | 12-month LP lock, verified contract, open source |
| **Owner price dump** | 🟡 Medium | Only 3% of supply unlocked at TGE — limited downside |
| **Team dump post-vest** | 🟢 Low | 7% distributed via vesting — gradual release |
| **Low post-launch volume** | 🟡 Medium | Treasury-funded marketing + buyback program |
| **Smart contract bug** | 🟡 Medium | Open source + third-party audit |
| **Mint not fully sold** | 🟢 Low | Remaining mint supply can be burned or transferred to treasury |

---

## 8. Review Checklist

- [x] Total supply: 55 + 25 + 10 + 10 = 100%
- [x] Team split: 3% owner (unlocked) + 7% vesting
- [x] Mint fee split: $0.30 owner + $0.70 LP = $1.00
- [x] Max mints: 5,500 × 100K = 550M ✓
- [x] LP lock: 12 months
- [x] Team cliff: 3 months
- [x] Team vest: 3 months linear (6 months total)
- [x] V4 Hook dynamic fee: 1% low, 1.5% high
- [x] Fee splitter: owner 0.484% + treasury 0.2%
- [x] Revenue projections calculated
- [x] Risk matrix documented

---

*Next: **Phase 1 — Smart Contracts** 🟡*
