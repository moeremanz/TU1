# 06 — Liquidity Mechanism 💧

> *How TU1 bootstraps DEX liquidity without external capital.*
> *Every mint funds the LP pool — organic, sustainable, trustless.*

---

## Core Concept

TU1's liquidity is **self-bootstrapping**. Unlike traditional launches that require:
- ❌ A large ETH deposit from the team
- ❌ VC or investor capital
- ❌ Pre-sales to raise LP funds

TU1 generates its own liquidity from **mint fees**:

```
┌────────────────────────────────────────────────────────────────────┐
│                    SELF-BOOTSTRAPPING LP                            │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  Mint Phase (3 days)                                               │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ User mint: pays $1 ETH                                     │  │
│  │   ├── $0.30 → Owner (dev, infra)                           │  │
│  │   ├── $0.70 → LP Escrow (ETH accumulating)                  │  │
│  │   └── 100K TU1 → User wallet                                │  │
│  │                                                             │  │
│  │ 5,500 mints max → $3,850 ETH + 250M TU1 ready for LP       │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                           ↓                                       │
│  Day 3 (mint ends)                                                │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ Create Bankr pool:                                          │  │
│  │   250M TU1 + accumulated ETH                                │  │
│  │   → LP tokens locked 12 months                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

---

## LP Components

### What Goes Into the LP

| Component | Source | Amount (at full mint) |
|-----------|--------|----------------------|
| **TU1 Tokens** | Supply allocation (25%) | 250,000,000 TU1 |
| **ETH** | Mint fees ($0.70 per mint) | ~$3,850 ETH |
| **Total LP Value** | | ~$3,850 + 250M TU1 |

### What Comes Out

| Output | Detail |
|--------|--------|
| **LP Tokens** | Represent ownership of the pool |
| **LP Lock** | Locked for 12 months (non-withdrawable) |
| **Swap Fee** | V4 Hook auto-collects 1% / 1.5% on every trade |

---

## Mint Fee Escrow Contract

During the 3-day mint, ETH from mint fees accumulates in an escrow:

```solidity
contract MintEscrow {
    uint256 public totalETHCollected;
    address public immutable lpRecipient; // deployer
    uint256 public immutable mintEndTime;
    
    function collect(address user) external payable {
        require(msg.sender == tu1Contract, "Only TU1");
        totalETHCollected += msg.value;
    }
    
    function releaseLP() external {
        require(block.timestamp >= mintEndTime, "Mint not ended");
        // All ETH goes to deployer for Bankr LP creation
        payable(lpRecipient).transfer(totalETHCollected);
    }
}
```

> **Note:** This can also be a simple ETH balance in the TU1 contract itself — no separate escrow needed if the TU1 contract has a `releaseLPMintFee()` function.

---

## Liquidity Scenarios

### Best Case: Full Mint (5,500 mints)

```
Mints:      5,500 × $1.00 = $5,500
├── Owner:  5,500 × $0.30 = $1,650
├── LP ETH: 5,500 × $0.70 = $3,850
└── TU1:    5,500 × 100K  = 550M TU1 minted

LP Pool: 250M TU1 + $3,850 ETH
```

### Moderate: 50% Mint (2,750 mints)

```
Mints:      2,750 × $1.00 = $2,750
├── Owner:  2,750 × $0.30 = $825
├── LP ETH: 2,750 × $0.70 = $1,925
└── TU1:    2,750 × 100K  = 275M TU1 minted (275M burned)

LP Pool: 250M TU1 + $1,925 ETH
```

### Low: 20% Mint (1,100 mints)

```
Mints:      1,100 × $1.00 = $1,100
├── Owner:  1,100 × $0.30 = $330
├── LP ETH: 1,100 × $0.70 = $770
└── TU1:    1,100 × 100K  = 110M TU1 minted (440M burned)

LP Pool: 250M TU1 + $770 ETH
```

> **Even at 20% mint, LP is bootstrapped.** Smaller pool but zero debt — the project has no obligations.

---

## Bankr Integration

[Bankr](https://bankr.chat) is the intended launchpad for TU1's DEX pool:

| Step | Action |
|------|--------|
| 1 | Deploy TU1 + TU1Mirror + TeamVesting + FeeSplitter |
| 2 | Open mint (3 days) — ETH accumulates |
| 3 | Mint ends — unsold TU1 burned |
| 4 | Deployer approves 250M TU1 to Bankr |
| 5 | Deployer deposits 250M TU1 + accumulated ETH → Bankr pool |
| 6 | LP tokens sent to lock contract (12 months) |
| 7 | V4 Hook registered on pool |
| 8 | FeeSplitter configured for creator share |
| 9 | Trading begins |

---

## LP Lock Mechanism

| Parameter | Value |
|-----------|-------|
| **LP Lock Duration** | 12 months |
| **Lock Contract** | Standard token lock (e.g., team-finance style) |
| **Who Can Unlock** | Owner (only after 12 months) |
| **Early Unlock** | ❌ Impossible |
| **LP Tokens Visibility** | Public on block explorer — verifiable |

---

## Post-Launch LP Management

After launch, the treasury (100M TU1) can be used for LP management:

| Action | How | Effect |
|--------|-----|--------|
| **Add LP** | Treasury buys TU1 from market + pairs with treasury ETH | Deepens liquidity |
| **Rebalance** | Adjust TU1/ETH ratio based on market conditions | Stabilizes pool |
| **Migration** | Move to larger DEX (Uniswap V3, Aerodrome, etc.) | More volume |
| **Incentives** | Reward LP providers with TU1 from treasury | Attracts external LP |

---

## Security Considerations

| Issue | Risk | Mitigation |
|-------|------|------------|
| LP too thin after low mint | 🟡 Medium | Even $770 ETH + 250M TU1 is tradeable |
| Mint fee frontrunning | 🟢 Low | Fee is fixed in contract — no MEV |
| LP lock bypass | 🟢 Low | Lock contract is immutable |
| Deployer rug | 🟡 Medium | LP lock prevents — but deployer still has 30M unlocked |
| Impermanent loss | 🟡 Medium | LP lock means LPs (including team) accept IL risk |

---

## Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    LIQUIDITY ECOSYSTEM                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    MINT FEES ($0.70/mint)                                        │
│         ↓                                                        │
│    ┌──────────────────────┐                                      │
│    │    ETH ESCROW        │    250M TU1 SUPPLY                   │
│    │    ($3,850 max)      │    (25% allocation)                  │
│    └──────────┬───────────┘         │                            │
│               ↓                     ↓                            │
│         ┌────────────────────────────────┐                      │
│         │         BANRK POOL             │                      │
│         │    TU1 / ETH LP (6 decimals)  │                      │
│         │    Fee: 1% / 1.5% (V4 Hook)  │                      │
│         └────────────────────────────────┘                      │
│                      ↓                                          │
│         ┌────────────────────────┐                              │
│         │   LP LOCK (12 months)  │                              │
│         └────────────────────────┘                              │
│                                                                  │
│    NO EXTERNAL CAPITAL NEEDED. ALL ORGANIC FROM MINT.           │
└─────────────────────────────────────────────────────────────────┘
```
