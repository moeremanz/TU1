# 10 — Implementation Plan 🛠️

> *Adopting Khora's proven 4-contract architecture for TU1.*
> *Production-tested, secure, on-chain metadata.*

---

## Current State

| Contract | Status | Lines | Notes |
|----------|--------|-------|-------|
| **TU1.sol** | ✅ Written | 107 | ERC-20 + DN-404 base, mint, burn, treasury |
| **TU1Mirror.sol** | ✅ Written | 150 | DN-404 Mirror + ERC-8004 registry calls |
| **TeamVesting.sol** | ✅ Written | ~100 | 3mo cliff + 3mo linear |
| **FeeSplitter.sol** | ✅ Written | ~50 | Owner/treasury split |

## Target Architecture (Khora-Inspired)

```
┌──────────────────────────────────────────────────────────────┐
│                    TU1 V2 (4-Contract System)                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ TU1.sol      │  │ TU1Mirror.sol│  │ TU1Storage.sol│     │
│  │ (DN-404)     │  │ (Renderer)   │  │ (SSTORE2)    │      │
│  │              │  │              │  │              │      │
│  │ ERC-20       │  │ tokenURI()   │  │ bitmap data  │      │
│  │ NFT auto     │  │ renderSVG()  │  │ traits JSON  │      │
│  │ Mint logic   │  │ Sanitize     │  │ on-chain     │      │
│  │ Treasury     │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ TU1Minter.sol                                             ││
│  │ - Signature verification (EIP-712)                        ││
│  │ - Phase system (Closed → Allowlist → Public)              ││
│  │ - Rate limiting (on-chain)                                ││
│  └──────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────┘
```

---

## Contract Mapping (Khora → TU1)

| Khora Contract | TU1 Equivalent | Lines (est) | Purpose |
|----------------|---------------|-------------|---------|
| BOOAv2 (ERC-721) | TU1.sol (DN-404) | ~150 | NFT + ERC-20 hybrid |
| BOOAStorage (SSTORE2) | TU1Storage.sol | ~200 | On-chain bitmap + traits |
| BOOARenderer (SVG) | TU1Mirror.sol | ~250 | tokenURI + renderSVG |
| BOOAMinter (Mint) | TU1Minter.sol | ~300 | Signature mint + phases |

---

## Implementation Steps

### Phase 1: SSTORE2 Storage (Week 1)

**File:** `src/TU1Storage.sol`

```solidity
// SSTORE2 pattern: deploy contract per token
// Data stored as contract bytecode
// Read via extcodecopy (400 gas, regardless of size)

contract TU1Storage {
    // Deploy storage for a token
    function deployStorage(uint256 tokenId, bytes calldata data) external;
    
    // Read stored data
    function readStorage(uint256 tokenId) external view returns (bytes memory);
    
    // Check if storage exists
    function hasStorage(uint256 tokenId) external view returns (bool);
}
```

**Key Decisions:**
- Max data size: 24KB (SSTORE2 limit)
- Bitmap: 2,048 bytes (64×64 × 4-bit palette)
- Traits: ~1KB (JSON attributes)
- Gas cost: ~200K per storage deploy

### Phase 2: On-Chain SVG Renderer (Week 1)

**File:** Update `src/TU1Mirror.sol`

```solidity
// Add to TU1Mirror:
function renderSVG(uint256 tokenId) public pure returns (string memory);
function tokenURI(uint256 id) public view override returns (string memory);
```

**Rendering Logic:**
1. Read 2,048 bytes from TU1Storage
2. Map palette index → C64 color
3. Generate SVG with `<rect>` elements
4. Return `data:image/svg+xml;base64,...`

### Phase 3: Signature Minter (Week 2)

**File:** `src/TU1Minter.sol`

```solidity
// EIP-712 signature verification
// Phase system: Closed → Allowlist → Public
// Rate limiting: max per wallet

contract TU1Minter {
    function mint(
        bytes calldata imageData,
        bytes calldata traitsData,
        uint256 deadline,
        bytes calldata signature,
        bytes32[] calldata merkleProof
    ) external payable returns (uint256 tokenId);
}
```

**Signature Schema:**
```solidity
// keccak256(abi.encode(
//   imageData,    // 2048 bytes hex
//   traitsData,   // JSON attributes hex
//   minterAddress,
//   deadline,     // 10 minutes
//   chainId,
//   contractAddress
// ))
```

### Phase 4: Integration (Week 2)

**Update TU1.sol:**
- Add `mint()` function that calls TU1Minter
- Add phase management
- Add allowlist support

**Update TU1Mirror.sol:**
- Integrate with TU1Storage for tokenURI
- Add renderSVG function
- Add SVG sanitization

### Phase 5: Testing (Week 3)

**Test Suite:**
1. SSTORE2 deploy + read
2. SVG rendering consistency
3. Signature verification
4. Phase transitions
5. Rate limiting
6. Gas optimization

### Phase 6: Audit + Deploy (Week 4)

1. Internal audit (all 4 contracts)
2. Deploy to Base Sepolia
3. Integration test with website
4. Mainnet deployment

---

## Gas Estimates

| Action | Khora (Shape) | TU1 (Base) | Notes |
|--------|--------------|------------|-------|
| Deploy Storage | ~200K gas | ~200K gas | Same SSTORE2 pattern |
| Deploy Renderer | ~500K gas | ~500K gas | Pure functions |
| Deploy Minter | ~300K gas | ~300K gas | Signature verification |
| mint() | ~150K gas | ~150K gas | Storage + render |
| tokenURI() | ~100K gas | ~100K gas | Read + render |
| register() | ~80K gas | ~80K gas | ERC-8004 registry |

---

## Cost Breakdown

| Item | Cost | Notes |
|------|------|-------|
| Deploy TU1Storage | ~$0.50 | SSTORE2 pattern |
| Deploy TU1Mirror | ~$1.25 | Renderer + ERC-8004 |
| Deploy TU1Minter | ~$0.75 | Signature verification |
| Storage per token | ~$0.50 | 2KB on-chain |
| **Total per NFT** | **~$3.00** | Including storage |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| SSTORE2 deployment fails | Low | High | Test on Sepolia first |
| SVG rendering bug | Medium | High | Comprehensive test suite |
| Signature replay | Low | Critical | Deadline + chainId binding |
| Gas spike on Base | Medium | Medium | Monitor + optimize |
| ERC-8004 registry issue | Low | High | Use proven address |

---

## Success Criteria

1. ✅ All 4 contracts compile
2. ✅ SSTORE2 storage works (2KB per token)
3. ✅ SVG rendering produces valid output
4. ✅ Signature verification passes
5. ✅ Gas < 200K per mint
6. ✅ 18/18 existing tests pass
7. ✅ Integration test with website
