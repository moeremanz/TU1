# 05 — Treasury & Roadmap 🗺️

> *Revenue model, treasury management, and development timeline.*
> *Mint fees bootstrap LP — no external capital needed.*

---

## Treasury Sources

| Source | Rate | Destination |
|--------|------|-------------|
| **Mint Fee (LP portion)** | $0.70/mint | Bootstraps DEX LP (3 days) |
| **Swap Fee** (V4 Hook) | 0.20% of volume | Treasury |
| **Subscription Fee** (Crypto Graph) | 10% of subscription | Treasury |
| **Unsold Mint Burn** | 100% of remaining | Deflationary |

### LP Bootstrap from Mint

| Mints Sold | ETH Collected (LP Pool) | Paired with TU1 | Est. LP Value |
|-----------|------------------------|----------------|--------------|
| 1,000 | $700 | 250M TU1 | ~$700 + 250M TU1 |
| 2,500 | $1,750 | 250M TU1 | ~$1,750 + 250M TU1 |
| 5,500 (full) | $3,850 | 250M TU1 | ~$3,850 + 250M TU1 |

> 🧠 **No treasury funds needed for LP.** The mint itself generates the ETH liquidity through fees.

### Revenue Scenarios (Post-Mint)

| Daily Volume | Treasury/day | Treasury/month |
|-------------|--------------|----------------|
| $5K | $15 | $450 |
| $50K | $100 | $3,000 |
| $500K | $1,000 | $30,000 |
| $1M | $2,000 | $60,000 |
| $5M | $10,000 | $300,000 |

### Subscription Revenue

| Subscribers | 🔥 Burn/month | 🏦 Treasury/month |
|-------------|--------------|-------------------|
| 100 | $45 | $5 |
| 1,000 | $450 | $50 |
| 10,000 | $4,500 | $500 |

---

## Treasury Allocation

| Allocation | % | Monthly @ $1M vol |
|------------|---|-------------------|
| 🎁 **Community Rewards** | 30% | $18,000 |
| 🤖 **Agent Development** | 40% | $24,000 |
| 📢 **Marketing & Growth** | 20% | $12,000 |
| 💼 **Operations** | 10% | $6,000 |

### Community Rewards (30%)
- TU1 staking rewards
- Liquidity incentives
- Referral programs
- Competitions & airdrops

### Agent Development (40%)
- AI compute infrastructure
- Model improvements
- Crypto Graph enhancements
- Server costs

### Marketing & Growth (20%)
- Exchange listings
- Partnership development
- Campaigns & events
- Content creation

### Operations (10%)
- Smart contract audits
- Legal & compliance
- Admin & tools

---

## Fee Splitter

The FeeSplitter contract automatically distributes Bankr's creator share:

```
Bankr sends creator share (0.684%) to FeeSplitter
                      ↓
         ┌──────────────────────┐
         │    FeeSplitter       │
         ├──────────────────────┤
         │ Owner:    70.76%    │ → 0.484% of volume
         │ Treasury: 29.24%    │ → 0.200% of volume
         └──────────────────────┘
```

Both ETH and ERC-20 distributions are supported.

---

## Pipeline (End-to-End Flow)

```
┌─────────────────────────────────────────────────────────────────┐
│                     TU1 PIPELINE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: CONCEPT + DOCS  ◄── YOU ARE HERE                      │
│  ├── Tokenomics, architecture, agent identity                   │
│  └── Smart contracts, mint flow, treasury                       │
│                                                                  │
│  STEP 2: CONTRACTS DEPLOYED                                     │
│  ├── TU1.sol + TU1Mirror.sol → Base Sepolia testnet            │
│  ├── TeamVesting.sol + FeeSplitter.sol                          │
│  ├── Test: signature mint, ERC-8004 call, DN-404 dynamics      │
│  └── ✅ All 18 tests passing                                    │
│                                                                  │
│  STEP 3: MINT LAUNCH (3 days)                                   │
│  ├── Agent live on Telegram → riddle + sign permits            │
│  ├── Users mint TU1 → pay $1 ETH                               │
│  ├── ├── $0.30 → owner wallet                                  │
│  │   └── $0.70 → LP pool (ETH accumulating)                    │
│  └── 550M TU1 distributed OR burned after 3 days               │
│                                                                  │
│  STEP 4: DEX LISTING (Day 3)                                    │
│  ├── 250M TU1 + accumulated ETH → Bankr pool                   │
│  ├── LP tokens locked 12 months                                 │
│  ├── V4 Hook activated (dynamic fee 1%/1.5%)                   │
│  └── FeeSplitter live → auto-distribute                        │
│                                                                  │
│  STEP 5: TREASURY RELEASE                                       │
│  ├── 100M TU1 → agentic wallet                                 │
│  ├── Treasury manager AI active: buyback, rewards              │
│  └── 30% community / 40% agent / 20% marketing / 10% ops       │
│                                                                  │
│  STEP 6: SUBSCRIPTION + ECOSYSTEM                               │
│  ├── TU1 Crypto Graph live ($0.50/mo)                          │
│  ├── 90% burn → deflationary                                   │
│  ├── 10% treasury → sustainable income                         │
│  └── Community rewards, reputation registry, staking           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Roadmap

### Phase 0-1: Foundation ✅ Done

| Item | Status |
|------|--------|
| Tokenomics design | ✅ Complete |
| TU1.sol (DN-404 base) | ✅ Written |
| TU1Mirror.sol (DN-404 Mirror + ERC-8004) | ✅ Written |
| TeamVesting.sol | ✅ Written |
| FeeSplitter.sol | ✅ Written |
| TU1Hook.sol (V4) | ✅ Written (pending deps) |
| forge tests | ✅ 18/18 passing |
| All 9 docs complete | ✅ Done |

### Phase 2: Deploy to Testnet 🔜 Next

| Item | Status |
|------|--------|
| Request Base Sepolia ETH (faucet) | 🔜 Next |
| Deploy TU1.sol + TU1Mirror.sol | 🔜 Next |
| Deploy TeamVesting + FeeSplitter | 🔜 Next |
| Test signature mint end-to-end | 🔜 Next |
| Test ERC-8004 global registry call | 🔜 Next |
| Test DN-404 dynamics (auto-mint/burn) | 🔜 Next |
| Verify contracts on block explorer | 🔜 Next |
| Agent code audit & review | 🔜 Next |

### Phase 3: Mint Launch (3 days)

| Item | Description |
|------|-------------|
| **Deploy to mainnet** | All contracts on Base |
| **Fund LP** | Deployer creates Bankr pool with 250M TU1 + accumulated ETH |
| **Open mint** | Agent generates riddles, signs permits |
| **3-day mint window** | Users mint TU1 + NFT + agent identity |
| **Unsold burn** | Burn remaining mint supply |
| **Treasury release** | 100M TU1 → agentic wallet |

### Phase 4: DEX Trading

| Item | Description |
|------|-------------|
| **Bankr pool active** | TU1 trades on DEX |
| **V4 Hook live** | Dynamic fee (1% / 1.5%) |
| **FeeSplitter live** | Auto-distribution every swap |
| **LP locked 12 months** | LP tokens in lock contract |

### Phase 5: TU1 Crypto Graph

| Item | Description |
|------|-------------|
| **Product live** | Daily AI market briefing at 07:00 WIB |
| **Subscription smart contract** | Pay TU1 → 90% burn, 10% treasury |
| **Launch week discount** | $0.30 USD / month |
| **Agent delivery** | Auto-send to Telegram subscribers |

### Phase 6: Ecosystem Growth

| Item | Description |
|------|-------------|
| **Community rewards** | 30% treasury begins distribution |
| **Staking** | Stake TU1 for rewards |
| **ERC-8004 Reputation Registry** | Feedback + scoring |
| **Marketing push** | Listings, partnerships, campaigns |

---

## Milestone Triggers

| Milestone | Trigger | Window |
|-----------|---------|--------|
| **Testnet Deploy** | Docs complete + faucet secured | Day 0 |
| **Mint Launch** | Testnet verified + audited | Day 3 |
| **DEX Listing** | Mint sold out OR 3 days elapsed | Day 3 max |
| **Crypto Graph Launch** | Agent operational + website ready | Month 1-2 |
| **Community Rewards** | Treasury accumulated sufficient funds | Month 1+ |
| **Reputation Registry** | Core contracts stable | Month 3+ |
