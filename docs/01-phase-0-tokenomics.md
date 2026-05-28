# Phase 0: Tokenomics & Parameters 🔴

> *The foundation — define every number before writing a single line of code.*

## 1. Token Parameters

| Parameter | Value |
|-----------|-------|
| **Token Name** | TU1 |
| **Symbol** | TU1 |
| **Network** | Base (Ethereum L2) |
| **Total Supply** | 1,000,000,000 (1B) |
| **Decimals** | 18 |
| **Standard** | ERC-20 |

## 2. Supply Allocation

| Allocation | Amount | % of Supply |
|------------|--------|-------------|
| **Mint** | 550,000,000 | 55% |
| **LP (Liquidity Pool)** | 250,000,000 | 25% |
| **Treasury** | 100,000,000 | 10% |
| **Team** | 100,000,000 | 10% |

### Mint Allocation (55%)
The majority of supply goes to the community via riddle-based minting. No pre-mine, no insider allocation.

### LP Allocation (25%)
- **Locked** for 12 months post-launch
- Provides initial DEX liquidity on Uniswap V4
- Continuously replenished by mint fee (70% of mint fee → LP)

### Treasury Allocation (10%)
- Managed by Hermes AI agent via agentic wallet
- Funds: buyback, marketing, development, community rewards
- Continuously supplemented by fee splitter (0.2% of all swap volume)

### Team Allocation (10%)
- **Vested** over 2 years (linear unlock)
- 3-month cliff before first unlock
- Transparent vesting contract — verifiable on-chain

## 3. Mint Mechanism

### Parameters

| Parameter | Value |
|-----------|-------|
| **Mint Price** | $1 |
| **Tokens per Mint** | 100,000 TU1 |
| **Max Mint per Wallet** | 10 |
| **Total Mints Available** | 5,500 |
| **Total Mint Supply** | 550,000,000 TU1 |
| **Mint Method** | Riddle-based (see Phase 2) |

### Fee per Mint ($1)

| Destination | Amount | Purpose |
|-------------|--------|---------|
| **Owner** | $0.30 | Development, infrastructure, operations |
| **LP Pool** | $0.70 | DEX liquidity foundation |

### Revenue Projection

If all 5,500 mints are sold:

| Source | Revenue |
|--------|---------|
| **Owner Revenue** | $1,650 |
| **LP Contribution** | $3,850 |
| **Total Mint Revenue** | $5,500 |

> **Note:** LP contribution is NOT revenue — it provides liquidity for the DEX pool, enabling trading.

## 4. Trading Fee Structure (Uniswap V4 Hook)

After launch, a dynamic fee is applied to all swap volume via a custom Uniswap V4 Hook contract.

### Low Volume Mode (< $5,000/day)

| Component | Fee % | Daily at $5K vol |
|-----------|-------|-------------------|
| **LP Rewards** | 0.70% | $35 |
| **Treasury** | 0.30% | $15 |
| **Total Fee** | 1.00% | |

### High Volume Mode (≥ $5,000/day)

| Component | Fee % | Daily at $1M vol |
|-----------|-------|-------------------|
| **LP Rewards** | 0.60% | $6,000 |
| **Treasury (via Fee Splitter)** | 0.20% | $2,000 |
| **Owner (via Fee Splitter)** | 0.484% | $4,840 |
| **Bankr Creator Fee** | 0.216% | — (platform fee) |
| **Total Fee** | 1.50% | $12,840 |

### Fee Splitter Logic

The Bankr platform takes 0.216% as creator fee. The remaining creator share (0.684%) is split:

```
Bankr Creator Share: 0.684% of volume
  ├── 👑 Owner: 0.484% (70.76% of creator share)
  └── 🏦 Treasury: 0.200% (29.24% of creator share)
```

### Projected Daily Revenue

| Volume Scenario | Owner | Treasury | Total Ecosystem |
|-----------------|-------|----------|-----------------|
| $5K/day | $0 | $15 | $50 |
| $50K/day | $242 | $100 | $842 |
| $500K/day | $2,420 | $1,000 | $8,420 |
| $1M/day | $4,840 | $2,000 | $16,840 |
| $5M/day | $24,200 | $10,000 | $84,200 |
| $10M/day | $48,400 | $20,000 | $168,400 |

## 5. Uniswap V4 Hook — Dynamic Fee Logic

```solidity
// Pseudocode — simplified
function getFee(address, address, uint256 amount) returns (uint24) {
    uint256 dailyVolume = _getDailyVolume();
    if (dailyVolume < 5_000 USD) {
        return 10000; // 1.00% — low volume mode
    } else {
        return 15000; // 1.50% — high volume mode
    }
}
```

- **Low volume mode:** Prioritizes LP growth to attract traders
- **High volume mode:** Balanced — LP still strongest, treasury+owner earn proportionally
- Threshold checked every N blocks via oracle or accumulated volume tracking

## 6. Vesting & Locking Schedule

| Allocation | Lock | Vest | Notes |
|------------|------|------|-------|
| **LP** | 12 months | — | Locked in LP contract post-launch |
| **Team** | 3 months cliff | 24 months linear | Unlocks monthly after cliff |
| **Treasury** | — | — | Managed actively by agent |
| **Mint** | — | — | Instantly claimable on mint |

## 7. Risk & Mitigation

| Risk | Probability | Mitigation |
|------|-------------|------------|
| **Bot attack on mint** | Medium | Max 10 per wallet, CAPTCHA/riddle gate |
| **Liquidity rug** | Low | LP locked 12 months, transparent contract |
| **Team dump** | Low | 2-year vesting + 3-month cliff |
| **Low volume after launch** | Medium | Treasury-funded marketing, buyback incentive |
| **Smart contract bug** | Low | Open-source, audited (Phase 1) |

## 8. Key Parameters (Final Reference)

```
SUPPLY_TOTAL      = 1,000,000,000 TU1
SUPPLY_MINT       =   550,000,000 (55%)
SUPPLY_LP         =   250,000,000 (25%)
SUPPLY_TREASURY   =   100,000,000 (10%)
SUPPLY_TEAM       =   100,000,000 (10%)

MINT_PRICE        = $1
MINT_TOKENS       = 100,000 TU1
MAX_MINT_PER_WALLET = 10
TOTAL_MINTS       = 5,500

MINT_FEE_OWNER    = $0.30 (30%)
MINT_FEE_LP       = $0.70 (70%)

SWAP_FEE_LOW      = 1.00% (vol < $5K/day)
SWAP_FEE_HIGH     = 1.50% (vol ≥ $5K/day)

LP_LOCK           = 12 months
TEAM_CLIFF        = 3 months
TEAM_VEST         = 24 months
```

---

## Review Checklist

- [ ] Total supply adds up: 55 + 25 + 10 + 10 = 100%
- [ ] Mint fee split totals: 0.30 + 0.70 = $1.00
- [ ] Max mints: 5,500 × 100K = 550M ✓
- [ ] LP lock ensures minimum 12-month safety
- [ ] Team vest prevents early dump
- [ ] V4 Hook fee logic documented
- [ ] Revenue projections calculated and verified

---

*Next: Phase 1 — Smart Contracts* 🟡
