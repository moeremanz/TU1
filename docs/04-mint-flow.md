# 04 — Mint Flow ✍️

> *How users mint TU1 tokens and agent identity NFTs.*

---

## Overview

TU1 uses a **signature-based mint** model:

1. **Agent** generates and verifies riddles off-chain
2. **Agent** signs an EIP-712 permit authorizing the mint
3. **User** executes the mint transaction — paying their own gas
4. **Contract** verifies the signature, mints TU1 + NFT

This design keeps the agent as the **gatekeeper** (riddle solver) while allowing **unlimited scalability** (users pay gas, not the agent).

---

## Flow Diagram

```
🧑 USER                          🤖 AGENT (Hermes)                  ⛓️ CONTRACT
   │                                  │                                  │
   │  ── "I want to mint" ────────→  │                                  │
   │                                  │                                  │
   │                                  │  Generate riddle + answer hash   │
   │                                  │                                  │
   │  ←─ Riddle text ─────────────── │                                  │
   │                                  │                                  │
   │  ── Submit answer ────────────→  │                                  │
   │                                  │                                  │
   │                                  │  ✅ Verify answer                │
   │                                  │  Check: max 10 per wallet        │
   │                                  │  Check: riddle not reused        │
   │                                  │                                  │
   │                                  │  Create permit:                  │
   │                                  │    to: user                      │
   │                                  │    amount: 1-10                  │
   │                                  │    riddleHash: keccak(answer)    │
   │                                  │    nonce: user nonce             │
   │                                  │    deadline: now + 1 hour        │
   │                                  │                                  │
   │                                  │  Sign with agent's ECDSA key    │
   │                                  │                                  │
   │  ←─ Signature + riddleHash ──── │                                  │
   │      + amount + deadline         │                                  │
   │                                  │                                  │
   │  ── submitMint(                 │                                  │
   │       amount,                   │                                  │
   │       riddleHash,               │                                  │
   │       deadline,                 │                                  │
   │       signature                 │                                  │
   │     ) ──────────────────────────────────────────────────────────→  │
   │                                  │                                  │
   │                                  │           Verify signature ✅   │
   │                                  │           Check nonce ✅        │
   │                                  │           Check deadline ✅      │
   │                                  │           Check max 10 ✅        │
   │                                  │                                  │
   │                                  │           Mint TU1              │
   │                                  │           Auto-mint NFT         │
   │                                  │           (if ≥ 100K TU1)       │
   │                                  │                                  │
   │  ←─ "Minted! TU1 + NFT" ──────│──────────────────────────────── │
```

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

## Contract Function

```solidity
function submitMint(
    uint256 amount,       // 1-10 mints
    bytes32 riddleHash,   // keccak256(answer)
    uint256 deadline,     // timestamp — permit expires
    bytes calldata signature  // agent's ECDSA signature
) external nonReentrant;
```

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
| Contract has enough TU1 balance | `"Insufficient contract balance"` |
| `ECDSA.recover(hash, sig) == signer` | `"Invalid signature"` |

---

## Gas Costs (Base L2)

| Action | Gas Used | Cost (ETH) | Cost (USD) |
|--------|----------|------------|------------|
| `submitMint(1)` — 1 mint | ~80,000 | ~0.0000004 | ~$0.001 |
| `submitMint(10)` — 10 mints | ~120,000 | ~0.0000006 | ~$0.0015 |

> Base L2 gas price assumed: 0.005 gwei. ETH price: $2,500.

---

## Riddle Mechanics

| Aspect | Detail |
|--------|--------|
| **Complexity** | Medium — not too easy, not too hard |
| **Storage** | Off-chain (generated by agent) |
| **Verification** | Agent verifies off-chain, on-chain only stores hash |
| **Replay protection** | `usedRiddles` mapping prevents reuse |
| **Max mints per riddle** | 1 riddle = 1 signature = 1-10 mints |

### Riddle Examples

> "What cryptographic concept ensures that a transaction cannot be altered once confirmed?"
> *Answer: immutability*

> "What is the term for a small program stored on the blockchain that executes automatically?"
> *Answer: smart contract*

---

## Agent Signing Key

| Detail | Value |
|--------|-------|
| **Key type** | ECDSA (secp256k1) |
| **Storage** | Hermes agent environment |
| **Set in contract** | `setSigner(agentAddress)` |
| **Rotatable** | Yes — owner can update signer |
