# 07 — TU1 Crypto Graph 📊

> *Subscription-based AI daily market briefing, delivered daily.*
> *Pay with TU1 → 90% burned, 10% to treasury.*

---

## Product Overview

TU1 Crypto Graph is a **daily AI-generated crypto market briefing** delivered automatically every morning:

| Detail | Value |
|--------|-------|
| **Product** | AI-generated daily market briefing |
| **Delivery** | Telegram DM, daily |
| **Content** | Narrative trending, market overview, price data |
| **Format** | Scannable with box borders, concise key takeaways |
| **Price** | $0.50 USD/month (paid in TU1 at market rate) |
| **Launch Week** | $0.30 USD/month |
| **Burn** | 90% of TU1 → 🔥 permanently removed from supply |
| **Treasury** | 10% → agent development & infrastructure |
| **Skills Used** | `daily-crypto-briefing`, `market-sentiment` |

---

## Economic Model

### How It Works

```
User Subscribes (pays TU1)
         │
         ▼
┌─────────────────────────────────┐
│    Subscription Smart Contract  │
├─────────────────────────────────┤
│                                 │
│  Receives TU1 from user         │
│                                 │
│  Calculates market rate of TU1  │
│  at subscription time           │
│                                 │
│  90% → BURN (reduce supply)    │
│  10% → TREASURY                │
│                                 │
│  Emits SubscriptionActive event │
└─────────────────────────────────┘
         │
         ▼
Hermes Agent detects event
         │
         ▼
Generates daily briefing
         │
         ▼
Delivers to subscriber's Telegram
```

### Subscription Scenarios

| Subscribers | Monthly Revenue | 🔥 Burned | 🏦 Treasury |
|-------------|----------------|-----------|-------------|
| 100 | $50.00 | $45.00 | $5.00 |
| 500 | $250.00 | $225.00 | $25.00 |
| 1,000 | $500.00 | $450.00 | $50.00 |
| 10,000 | $5,000.00 | $4,500.00 | $500.00 |
| 50,000 | $25,000.00 | $22,500.00 | $2,500.00 |

> **At scale, subscription revenue becomes significant.**
> At 10K subscribers: $4,500/month burned = deflationary pressure + $500/month treasury income.

---

## Subscription Lifecycle

### Subscribe

```
1. User sends `/subscribe` to TU1 bot on Telegram
2. Bot calculates TU1 amount needed ($0.50 at current market price)
3. Bot generates a payment request (wallet address + amount)
4. User sends TU1 to subscription contract
5. Contract:
   a. Receives TU1
   b. Burns 90%
   c. Sends 10% to treasury
   d. Records subscription active for 30 days
6. Bot confirms subscription
```

### Daily Delivery

```
1. Hermes cron job fires
2. Agent generates daily briefing
3. Delivers to each active subscriber via Telegram DM
```

### Renewal / Expiry

| Scenario | What Happens |
|----------|-------------|
| **Auto-renew** | User pre-funds balance — contract deducts monthly |
| **Manual renew** | User sends `/subscribe` again — new 30-day period |
| **Expired** | Bot stops delivery after 30 days without payment |
| **Cancel** | User sends `/unsubscribe` — bot removes from list |

---

## Smart Contract Design

```solidity
contract TU1CryptoGraph {
    ITU1 public immutable tu1;
    address public treasury;
    uint256 public subscriptionPrice;  // in USD cents (50 = $0.50)
    uint256 public burnPercentage = 90;
    
    struct Subscription {
        uint256 expiry;      // timestamp
        uint256 paidTotal;   // lifetime TU1 paid
    }
    
    mapping(address => Subscription) public subscribers;
    
    event Subscribed(address user, uint256 amount, uint256 expiry);
    event BriefingDelivered(address user, uint256 day);
    
    function subscribe(uint256 amountTU1) external {
        // Calculate USD value of TU1 at current market rate
        // If sufficient for 1 month → activate/ extend subscription
        // Burn 90%, send 10% to treasury
        tu1.transferFrom(msg.sender, address(this), amountTU1);
        
        uint256 burnAmount = (amountTU1 * 90) / 100;
        uint256 treasuryAmount = amountTU1 - burnAmount;
        
        tu1.burn(burnAmount);
        tu1.transfer(treasury, treasuryAmount);
        
        subscribers[msg.sender].expiry = block.timestamp + 30 days;
        subscribers[msg.sender].paidTotal += amountTU1;
        
        emit Subscribed(msg.sender, amountTU1, block.timestamp + 30 days);
    }
    
    function isSubscriberActive(address user) external view returns (bool) {
        return subscribers[user].expiry > block.timestamp;
    }
}
```

> **Note:** The subscription contract can be added post-launch (Phase 5). Not part of initial deploy.

---

## Agent Implementation (Hermes)

The TU1 Crypto Graph is delivered by the **Hermes agent** via a cron job:

### Cron Job Config

```yaml
name: "TU1 Crypto Graph Daily"
schedule: "0 7 * * *"
skills:
  - daily-crypto-briefing
  - market-sentiment
  - crypto-market-environment
prompt: |
  Generate the daily TU1 Crypto Graph briefing.
  Format: scannable with box borders.
  Content: trending narratives, market overview, price data.
  Deliver to all active subscribers.
  If no subscriber data available, send to home channel as demo.
```

### Delivery

| Method | Detail |
|--------|--------|
| **Telegram DM** | Direct message to each subscriber |
| **Home Channel** | Public preview (if subscriber count > 0) |
| **Fallback** | Archive to local file |

---

## Pricing

| Period | Price | Burn (90%) | Treasury (10%) |
|--------|-------|-----------|----------------|
| **Launch Week** | $0.30 USD | $0.27 | $0.03 |
| **Standard** | $0.50 USD | $0.45 | $0.05 |
| **Bulk (Annual)** | $5.00 USD | $4.50 | $0.50 |

### Dynamic TU1 Amount

The USD → TU1 conversion is calculated at subscription time:

```
TU1 needed = (USD Price × oraclePriceTU1) / 1e18
```

If TU1 price is $0.01:
- Standard subscription: 50 TU1 ($0.50)
- Launch week: 30 TU1 ($0.30)
- Annual: 500 TU1 ($5.00)

---

## Roadmap Integration

| Phase | Item |
|-------|------|
| **Phase 0-2** | Smart contracts + agent setup |
| **Phase 3** | Mint launch |
| **Phase 4** | DEX listing + trading |
| **Phase 5 🎯** | **TU1 Crypto Graph goes live** |
| **Phase 6** | Scale subscriptions + add features |

---

## Why This Model Works

| Factor | Benefit |
|--------|---------|
| **90% Burn** | Strong deflationary pressure on TU1 supply |
| **Recurring Revenue** | Predictable monthly income for treasury |
| **Agent-Automated** | Zero marginal cost per subscriber |
| **Daily Engagement** | Keeps users interacting with TU1 ecosystem |
| **Pay-with-TU1** | Creates natural buy pressure (users buy TU1 to subscribe) |
