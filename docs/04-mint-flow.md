# 04 — Mint Flow ✍️

> *How users mint TU1 tokens and agent identity NFTs via the website payment gateway.*
> *Website → Agent API → Smart Contract.*

---

## Overview

TU1 uses a **website-based mint with Agent API backend**:

1. **User** visits website → connects wallet → clicks "Mint"
2. **Website** fetches riddle from Agent API → shows to user
3. **User** submits answer → **Website** sends to Agent API for verification
4. **Agent API** verifies answer → returns ✅ + signs EIP-712 permit
5. **Website** shows payment prompt → **User** approves $1 ETH via WalletConnect
6. **Website** forwards ETH + calls Agent API with payment proof
7. **Agent API** calls `submitMint()` on contract with signature
8. **Contract** verifies → mints TU1 + NFT + registers on ERC-8004

This design keeps the **agent as gatekeeper** (riddle verifier + signer) while the **website handles UX and payment**.

---

## Flow Diagram

```
🧑 USER                    🌐 WEBSITE                  🤖 AGENT API            ⛓️ CONTRACT
   │                         │                            │                       │
   │── Connect Wallet ──────→│                            │                       │
   │                         │                            │                       │
   │── Click "Mint" ────────→│                            │                       │
   │                         │                            │                       │
   │                         │── Request riddle ────────→│                       │
   │                         │    (GET /api/riddle)       │                       │
   │                         │                            │  Generate riddle      │
   │                         │                            │  Hash answer          │
   │                         │                            │  Store riddleHash     │
   │                         │←───── Riddle JSON ────────│                       │
   │                         │    {riddle, sessionId}     │                       │
   │                         │                            │                       │
   │←── Riddle displayed ───│                            │                       │
   │    "What makes TU1 NFTs │                            │                       │
   │     agent identities?"  │                            │                       │
   │                         │                            │                       │
   │── Type answer ─────────→│                            │                       │
   │                         │                            │                       │
   │                         │── Verify answer ─────────→│                       │
   │                         │    POST /api/verify        │                       │
   │                         │    {sessionId, answer}     │                       │
   │                         │                            │  keccak256(answer)    │
   │                         │                            │  == riddleHash?       │
   │                         │                            │  Check max 10/wallet  │
   │                         │                            │                       │
   │                         │←──── ✅ Verified ─────────│                       │
   │                         │    {signature, permit}     │                       │
   │                         │                            │                       │
   │←── Payment prompt ─────│                            │                       │
   │    "$1.00 ETH required"│                            │                       │
   │                         │                            │                       │
   │── Approve tx ──────────→│  (WalletConnect popup)     │                       │
   │    (signs MetaMask)     │                            │                       │
   │                         │  ETH sent to contract      │                       │
   │                         │  via submitMint()          │                       │
   │                         │                            │                       │
   │                         │── submitMint(              │                       │
   │                         │     amount,                │                       │
   │                         │     riddleHash,            │                       │
   │                         │     deadline,              │                       │
   │                         │     signature              │                       │
   │                         │   ) ──────────────────────────────────────────→  │
   │                         │                            │                       │
   │                         │                            │    ✅ Verify sig      │
   │                         │                            │    ✅ Check nonce     │
   │                         │                            │    ✅ Check deadline  │
   │                         │                            │    ✅ Check max 10    │
   │                         │                            │                       │
   │                         │                            │    Mint 100K TU1      │
   │                         │                            │    Auto-mint NFT      │
   │                         │                            │    Fee: $0.30→owner   │
   │                         │                            │    Fee: $0.70→LP pool │
   │                         │                            │    Register ERC-8004  │
   │                         │                            │                       │
   │                         │←───── Event: Minted ──────│←───── ✅ Minted ─────│
   │                         │                            │                       │
   │←── 🎉 Success! ────────│                            │                       │
   │    "500,000 TU1 minted" │                            │                       │
   │    "5 Agent NFTs ready" │                            │                       │
```

> 🧠 **Fee Split:** When `submitMint` is called, the contract automatically:
> - Sends **$0.30** worth of ETH → owner wallet
> - Accumulates **$0.70** → LP pool (used for DEX liquidity at launch)
> - Mints **100,000 TU1** per unit → user wallet

---

## Payment Gateway

The website is the **payment gateway**. It handles ETH collection and calls the contract on behalf of the user.

### Why Website Instead of Direct Contract Call?

| Approach | UX | Security |
|----------|-----|----------|
| User calls `submitMint` directly | ❌ Complex — user needs to understand gas, ABIs | ✅ Trustless |
| Website calls `submitMint` | ✅ One-click payment | ✅ Agent still controls mint via signature |

The website:
1. Shows the riddle from Agent API
2. Collects payment ETH
3. Calls `submitMint()` with the agent's signature
4. User only needs to **approve one MetaMask popup**

### WalletConnect Flow

```
1. User clicks "Connect Wallet" → WalletConnect modal
2. User selects wallet (MetaMask, Trust, etc.)
3. User clicks "Mint" → solves riddle
4. User clicks "Pay $1" → MetaMask shows:
   ┌────────────────────────────────┐
   │  Confirm Transaction            │
   │  To: TU1 Contract               │
   │  Amount: 0.0004 ETH (~$1.00)    │
   │  Gas: ~$0.0015                  │
   │  ┌──────────┐  ┌──────────────┐ │
   │  │  Reject  │  │   Confirm    │ │
   │  └──────────┘  └──────────────┘ │
   └────────────────────────────────┘
5. User confirms → Website calls contract → TU1 minted!
```

---

## Agent API Endpoints

The Agent API is a backend service (Hermes) that the website calls:

### `GET /api/riddle`

```
Request: GET /api/riddle?wallet=0x...
Response:
{
  "sessionId": "abc123",
  "riddle": "What standard makes TU1 NFTs agent identities?",
  "riddleHash": "0xdef456...",
  "expiresAt": 1716900000
}
```

### `POST /api/verify`

```
Request:
{
  "sessionId": "abc123",
  "answer": "erc-8004",
  "wallet": "0x...",
  "amount": 5
}
Response (if correct):
{
  "status": "verified",
  "signature": "0xabc...",
  "to": "0x...",
  "amount": 5,
  "riddleHash": "0xdef...",
  "deadline": 1716900000
}
Response (if wrong):
{
  "status": "rejected",
  "reason": "Wrong answer"
}
```

---

## Submission to Contract

After payment, the website (or agent) calls:

```solidity
function submitMint(
    uint256 amount,       // 1-10 mints
    bytes32 riddleHash,   // keccak256(answer)
    uint256 deadline,     // timestamp — permit expires
    bytes calldata signature  // agent's ECDSA signature
) external payable;
```

### Who Pays Gas?

| Transaction | Who Pays | Gas Cost |
|------------|----------|----------|
| **submitMint** | Website backend (relayer) | ~$0.0015 |
| **ETH transfer** | User (via MetaMask popup) | ~$0.001 |

> The website can relay the transaction so the user pays only once (the ETH + gas bundle). Or the user pays gas directly — either way, ~$0.003 total.

### Validation Checks (in order)

| Check | Revert Message |
|-------|---------------|
| `block.timestamp <= deadline` | `"Permit expired"` |
| `mintOpened == true` | `"Mint not opened"` |
| `block.timestamp <= mintStartTime + 3 days` | `"Mint period ended"` |
| `1 <= amount <= 10` | `"Invalid amount"` |
| `mintedCount[user] + amount <= 10` | `"Max 10 per wallet"` |
| `usedRiddles[riddleHash] == false` | `"Riddle already used"` |
| `totalMintsExecuted + amount <= 5500` | `"Mint supply exhausted"` |
| `msg.value >= amount * mintPrice` | `"Insufficient payment"` |
| `ECDSA.recover(hash, sig) == signer` | `"Invalid signature"` |

---

## Signature Schema (EIP-712)

### TypeHash

```solidity
MintPermit(address to,uint256 amount,bytes32 riddleHash,uint256 nonce,uint256 deadline)
```

### Signing (Agent Side — Python)

```python
from eth_account import Account
from eth_account.messages import encode_typed_data

message = {
    "types": {
        "EIP712Domain": [
            {"name": "name", "type": "string"},
            {"name": "version", "type": "string"},
            {"name": "chainId", "type": "uint256"},
            {"name": "verifyingContract", "type": "address"},
        ],
        "MintPermit": [
            {"name": "to", "type": "address"},
            {"name": "amount", "type": "uint256"},
            {"name": "riddleHash", "type": "bytes32"},
            {"name": "nonce", "type": "uint256"},
            {"name": "deadline", "type": "uint256"},
        ],
    },
    "domain": {
        "name": "TU1",
        "version": "1",
        "chainId": 8453,  # Base mainnet
        "verifyingContract": "0x...TU1_ADDRESS",
    },
    "message": {
        "to": user_address,
        "amount": 5,
        "riddleHash": "0x...",
        "nonce": 0,
        "deadline": deadline,
    },
}

signed = Account.sign_typed_data(agent_key, message)
```

---

## Riddle Mechanics

| Aspect | Detail |
|--------|--------|
| **Complexity** | Medium — not too easy, not too hard |
| **Generation** | Agent API generates riddle on request |
| **Storage** | Off-chain (session-based, expires in 1 hour) |
| **Verification** | Agent verifies off-chain, contract only stores hash |
| **Replay protection** | `usedRiddles` mapping + 1-hour expiry |
| **Max mints per riddle** | 1 riddle = 1 signature = 1 session |

### Riddle Examples

> "What cryptographic concept ensures that a transaction cannot be altered once confirmed?"
> *Answer: immutability*

> "What is the term for a small program stored on the blockchain that executes automatically?"
> *Answer: smart contract*

> "What standard makes TU1 NFTs also AI agent identities?"
> *Answer: erc-8004*

---

## Agent Signing Key

| Detail | Value |
|--------|-------|
| **Key type** | ECDSA (secp256k1) |
| **Storage** | Hermes agent environment variable |
| **Usage** | Signs EIP-712 permits behind Agent API |
| **Set in contract** | `setSigner(agentAddress)` |
| **Rotatable** | Yes — owner can update signer |

---

## Gas Costs (Base L2)

| Action | Gas Used | Cost (ETH) | Cost (USD) |
|--------|----------|------------|------------|
| `submitMint(1)` — 1 mint | ~80,000 | ~0.0000004 | ~$0.001 |
| `submitMint(10)` — 10 mints | ~120,000 | ~0.0000006 | ~$0.0015 |
| User wallet approval | ~21,000 | ~0.0000001 | ~$0.0003 |

> Base L2 gas price assumed: 0.005 gwei. ETH price: $2,500.
