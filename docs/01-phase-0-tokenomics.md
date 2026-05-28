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

### 2.1 Team 10% — Detail Split

| Sub-Allocation | Amount | % Total | Vesting |
|----------------|--------|---------|---------|
| 👑 **Owner Wallet** | 30,000,000 TU1 | 3% | ✅ **No vesting** — cash out kapan saja |
| 🔒 **Team Vesting** | 70,000,000 TU1 | 7% | 🔴 Cliff 3 bln → 🟢 Linear 3 bln |

**Owner Wallet (30M TU1):**
- Dikirim langsung ke wallet owner saat deploy
- Tidak ada lock, tidak ada vesting
- Tuan bebas: transfer ke exchange, jadi LP, hold, cash out via Uniswap, atau bagi ke tim lain

**Team Vesting Wallet (70M TU1):**
- Terkunci di smart contract vesting
- Untuk: dev, advisor, operational team
- Distribusi internal diatur Tuan di luar kontrak

---

## 3. Mint Mechanism

| Parameter | Value |
|-----------|-------|
| **Mint Price** | $1 |
| **Tokens per Mint** | 100,000 TU1 |
| **Max Mint per Wallet** | 10 |
| **Total Mints Available** | 5,500 |
| **Total Mint Supply** | 550,000,000 TU1 |

### 3.1 Fee per Mint ($1)

| Destination | Amount | % | Purpose |
|-------------|--------|---|---------|
| 👑 **Owner** | $0.30 | 30% | Dev, infra, operational |
| 💧 **LP Pool** | $0.70 | 70% | DEX liquidity foundation |
| **TOTAL** | $1.00 | 100% ✓ | |

### 3.2 Revenue Projection (Full Mint)

```
Total Mint Revenue        = $5,500
├── 👑 Owner Revenue     = $1,650  (langsung — ke wallet owner)
└── 💧 LP Contribution   = $3,850  (ke pool — BUKAN revenue)
```

> **Catatan:** LP Contribution bukan revenue — masuk ke DEX pool sebagai initial liquidity agar trading bisa berjalan.

---

## 4. Lock & Vesting Schedule

### 4.1 👑 Owner Wallet — 30M TU1

| Status | Detail |
|--------|--------|
| ✅ **No lock** | Bisa cash out kapan saja |
| ✅ **No vesting** | 30M TU1 langsung accessible saat deploy |
| 🎯 **Tujuan** | Owner pribadi Tuan |

### 4.2 🔒 Team Vesting — 70M TU1

| Periode | Status | Yang Bisa Diclaim |
|---------|--------|-------------------|
| **Bulan 0 — Bulan 3** | 🔴 CLIFF | 0 TU1 (terkunci total) |
| **Bulan 3 — Bulan 6** | 🟢 LINEAR UNLOCK | ~777,778 TU1 per hari* |
| **Bulan 6+** | ✅ FULLY VESTED | 70,000,000 TU1 |

*\*Block-by-block linear vesting. Claimable kapan saja selama periode vesting. Semakin lama tunggu, semakin banyak yang bisa diclaim sekaligus.*

**Visual:**
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
      |  0      3                 6 bulan
```

### 4.3 💧 LP Lock — 250M TU1

| Status | Detail |
|--------|--------|
| 🔴 **Lock 12 bulan** | Tidak bisa ditarik sama sekali |
| ✅ **Post-lock** | Bisa dikelola owner (extend lock / withdrawal) |

---

## 5. Trading Fee Structure — Uniswap V4 Hook

### 5.1 Dynamic Fee Logic

```solidity
// Simplified pseudocode — the actual V4 Hook implementation
function getFee(volume24h) {
    if (volume24h < 5_000 USD) {
        return 1.00%;     // Low volume — prioritize LP growth
    } else {
        return 1.50%;     // High volume — balanced split
    }
}
```

### 5.2 Low Volume Mode (< $5,000/day)

| Component | Fee % | Daily @ $5K |
|-----------|-------|-------------|
| 💧 **LP Rewards** | 0.70% | $35 |
| 🏦 **Treasury** | 0.30% | $15 |
| **Total Fee** | **1.00%** | **$50** |

> Owner tidak mendapat bagian di low volume mode. Prioritas: memperkuat LP agar trader tertarik.

### 5.3 High Volume Mode (≥ $5,000/day)

| Component | Fee % | Daily @ $1M |
|-----------|-------|-------------|
| 💧 **LP Rewards** | 0.60% | $6,000 |
| 🏦 **Treasury (via Fee Splitter)** | 0.20% | $2,000 |
| 👑 **Owner (via Fee Splitter)** | 0.484% | $4,840 |
| 🏦 **Bankr Platform Fee** | 0.216% | $2,160 |
| **Total Fee** | **1.50%** | **$15,000** |

### 5.4 Fee Splitter Logic

Bankr mengambil 0.216% sebagai platform fee dari total 1.50%. Sisa 0.684% adalah **Creator Share** yang di-split:

```
Total Swap Fee: 1.50%
├── 💧 LP Rewards:       0.600% (40.0%)
├── 🏦 Bankr Platform:   0.216% (14.4%)
└── 🎯 Creator Share:    0.684% (45.6%)  ← Fee Splitter Contract
     ├── 👑 Owner:       0.484% (70.8% of creator share)
     └── 🏦 Treasury:    0.200% (29.2% of creator share)
```

### 5.5 Revenue Scenarios

| Volume | 👑 Owner/hari | 🏦 Treasury/hari | 💧 LP/hari |
|--------|--------------|-----------------|-----------|
| $5K | $0* | $15 | $35 |
| $50K | $242 | $100 | $350 |
| $500K | $2,420 | $1,000 | $3,500 |
| **$1M** | **$4,840** | **$2,000** | **$6,000** |
| $5M | $24,200 | $10,000 | $30,000 |
| $10M | $48,400 | $20,000 | $60,000 |

*\*Low volume mode — owner share belum aktif*

---

## 6. Final Reference — All Parameters

```
SUPPLY_TOTAL        = 1,000,000,000 TU1
SUPPLY_MINT         =   550,000,000 (55%)  → 5,500 mint × 100K
SUPPLY_LP           =   250,000,000 (25%)  → Lock 12 bulan
SUPPLY_TREASURY     =   100,000,000 (10%)  → Agentic wallet
SUPPLY_TEAM         =   100,000,000 (10%)
  ├── OWNER         =    30,000,000 (3%)   → ✅ No vesting
  └── VESTING       =    70,000,000 (7%)   → 🔴 Cliff 3 + 🟢 Linear 3

MINT_PRICE          = $1
MINT_TOKENS         = 100,000 TU1
MAX_MINT_PER_WALLET = 10
TOTAL_MINTS         = 5,500

MINT_FEE_OWNER      = $0.30 (30%) → langsung
MINT_FEE_LP         = $0.70 (70%) → ke pool

SWAP_FEE_LOW        = 1.00% (vol < $5K/day)
SWAP_FEE_HIGH       = 1.50% (vol ≥ $5K/day)
  LP    = 0.60%
  OWNER = 0.484%
  TRSRY = 0.200%
  BANKR = 0.216%

LP_LOCK             = 12 bulan
TEAM_CLIFF          = 3 bulan
TEAM_VEST           = 3 bulan linear (total 6 bulan dari deploy)
```

---

## 7. Risk & Mitigation

| Risk | Prob. | Mitigation |
|------|-------|------------|
| **Bot attack on mint** | 🟡 Medium | Max 10/wallet + riddle gate (Phase 2) |
| **Liquidity rug pull** | 🟢 Low | LP lock 12 bulan, kontrak verified, open source |
| **Owner dump price crash** | 🟡 Medium | Hanya 3% supply tanpa vesting — risiko terbatas |
| **Team dump after vest** | 🟢 Low | 7% terbagi, vesting 6 bulan — distribusi terukur |
| **Low volume after launch** | 🟡 Medium | Treasury-funded marketing + buyback program |
| **Smart contract bug** | 🟡 Medium | Open source + audit pihak ketiga |
| **Mint not fully sold** | 🟢 Low | Sisa mint supply bisa dibakar atau ditransfer ke treasury |

---

## 8. Review Checklist

- [x] Total supply adds up: 55 + 25 + 10 + 10 = 100%
- [x] Team split: 3% owner (no vest) + 7% vesting
- [x] Mint fee split: $0.30 owner + $0.70 LP = $1.00
- [x] Max mints: 5,500 × 100K = 550M ✓
- [x] LP lock: 12 bulan
- [x] Team cliff: 3 bulan
- [x] Team vest: 3 bulan linear (total 6 bulan)
- [x] V4 Hook dynamic fee: 1% low, 1.5% high
- [x] Fee splitter: owner 0.484% + treasury 0.2%
- [x] Revenue projections calculated
- [x] Risk matrix documented

---

*Next: **Phase 1 — Smart Contracts** 🟡*
