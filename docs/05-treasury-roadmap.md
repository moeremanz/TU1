# 05 — Treasury & Roadmap 🗺️

> *Revenue model, treasury management, and development timeline.*

---

## Treasury Sources

| Source | Rate | Destination |
|--------|------|-------------|
| **Swap Fee** (V4 Hook) | 0.20% of volume | Treasury |
| **Subscription Fee** (Crypto Graph) | 10% of subscription | Treasury |
| **Unsold Mint Burn** | 100% of remaining | Deflationary |

### Revenue Scenarios

| Daily Volume | Treasury/day | Treasury/month |
|-------------|--------------|----------------|
| $5K | $15 | $450 |
| $50K | $100 | $3,000 |
| $500K | $1,000 | $30,000 |
| $1M | $2,000 | $60,000 |
| $5M | $10,000 | $300,000 |

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

## Roadmap

### Phase 0-1: Foundation ✅ Done

| Item | Status |
|------|--------|
| Tokenomics design | ✅ Complete |
| TU1.sol (DN-404 base) | ✅ Written |
| TeamVesting.sol | ✅ Written |
| FeeSplitter.sol | ✅ Written |
| TU1Hook.sol (V4) | ✅ Written (pending deps) |
| forge tests | ✅ 18/18 passing |

### Phase 2: DN-404 + ERC-8004 🟡 In Progress

| Item | Status |
|------|--------|
| TU1Mirror.sol (extend DN404Mirror) | 🔜 Next |
| ERC-8004 Identity Registry integration | 🔜 Next |
| `setAgentURI()`, `getMetadata()` | 🔜 Next |
| `setAgentWallet()` with EIP-712 | 🔜 Next |
| forge tests for Mirror | 🔜 Next |
| Agent code review & audit | 🔜 Next |

### Phase 3: Mint Launch 📅

| Item | Description |
|------|-------------|
| **Deploy contracts** | TU1 + TU1Mirror + TeamVesting + FeeSplitter |
| **Open mint** | 3-day riddle-based mint on Base |
| **Unsold burn** | Burn remaining mint supply after 3 days |
| **Treasury release** | 100M TU1 → agentic wallet |

### Phase 4: DEX Listing 📅

| Item | Description |
|------|-------------|
| **Bankr launch** | Setup LP with 250M TU1 |
| **V4 Hook activation** | Dynamic fee live |
| **Fee Splitter live** | Automatic distribution |

### Phase 5: TU1 Crypto Graph 📅

| Item | Description |
|------|-------------|
| **Product live** | Daily AI market briefing |
| **Subscription smart contract** | Payment + burn + fee split |
| **Launch week discount** | $0.30 USD / month |

### Phase 6: Ecosystem Growth 📅

| Item | Description |
|------|-------------|
| **Community rewards** | 30% treasury begins distribution |
| **ERC-8004 Reputation Registry** | Feedback + scoring |
| **Staking** | Stake TU1 for rewards |
| **Partnerships** | Exchange listings, collaborations |

---

## Milestone Triggers

| Milestone | Trigger | Window |
|-----------|---------|--------|
| **Mint Launch** | Contracts deployed + audited | Day 0 |
| **DEX Listing** | Mint sold out OR 3 days elapsed | Day 3 max |
| **Crypto Graph Launch** | Agent operational + website ready | Month 1-2 |
| **Community Rewards** | Treasury accumulated sufficient funds | Month 1+ |
| **Reputation Registry** | After core contracts stable | Month 3+ |
