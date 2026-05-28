# NFT Image Generation — Khora-Style Pipeline

> Step-by-step guide to generate TU1 agent identity NFT images,
> matching Khora/BOOA's on-chain pixel art approach.

---

## How Khora Does It

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Agent Identity (Google Gemini)                      │
│  Input: "Generate a random AI agent identity"                │
│  Output: JSON { name, description, creature, vibe, ... }     │
│  Cost: ~$0.0001                                              │
├─────────────────────────────────────────────────────────────┤
│  STEP 2: Pixel Art (Retro Diffusion via Replicate)           │
│  Input: agent description text prompt                        │
│  Output: 384×384 pixel art PNG                               │
│  Cost: ~$0.005                                               │
├─────────────────────────────────────────────────────────────┤
│  STEP 3: C64 Processing (Client-Side JavaScript)             │
│  a) Downscale to 64×64                                       │
│  b) Bayer 4×4 dithering (10% strength)                       │
│  c) Quantize to C64 16-color palette                         │
│  d) Scale up to 1024×1024 (nearest-neighbor)                 │
│  Cost: $0                                                    │
├─────────────────────────────────────────────────────────────┤
│  STEP 4: On-Chain Storage                                    │
│  Convert to data URI: data:image/svg+xml;base64,...          │
│  Store in ERC-8004 registry tokenURI                         │
│  Cost: gas only (~$0.001 on Base)                            │
└─────────────────────────────────────────────────────────────┘
```

---

## For TU1 — Implementation Plan

### Option A: Full Khora Clone (Retro Diffusion)

**Requirements:**
- Replicate account (https://replicate.com)
- API token (`r8_...`)
- Retro Diffusion model access

**Script:**
```python
import replicate
import base64

def generate_agent_art(agent_description: str) -> str:
    """Generate pixel art from agent description."""
    output = replicate.run(
        "retro-diffusion/rd-plus",
        input={
            "prompt": agent_description,
            "style": "retro",
            "width": 384,
            "height": 384,
            "num_images": 1,
        }
    )
    return output[0]  # URL to generated image

def to_c64_pixel_art(image_url: str) -> str:
    """Apply C64 dithering + palette (port from pixelator.ts)."""
    # Download image
    # Downscale to 64×64
    # Apply Bayer 4×4 dithering
    # Quantize to C64 16-color palette
    # Scale up to 1024×1024
    return svg_data_uri
```

**Cost:** ~$0.005 per NFT × 5,500 = **$27.50 total**

### Option B: On-Chain SVG Trait Composition (Recommended)

**No external API needed. $0 cost.**

**How it works:**
1. Agent generates identity JSON (traits, skills, etc.)
2. Token ID → hash → select traits deterministically
3. Compose SVG from pre-made layers on-chain
4. Store as data URI in ERC-8004

**Layers:**
```
┌──────────────────────────┐
│  Layer 0: Background     │  ← 50 variants (cyber city, neon grid, etc.)
│  Layer 1: Creature       │  ← 100 variants (robot, dragon, alien, etc.)
│  Layer 2: Accessories    │  ← 200 variants (crown, sword, crystal, etc.)
│  Layer 3: Name Tag       │  ← Agent name + ID
│  Layer 4: Score Badge    │  ← Rank (S, A, B, C, D)
└──────────────────────────┘
```

**Unique combos:** 50 × 100 × 200 = **1,000,000+**

**Cost:** $0 (gas only)

### Option C: Hybrid (Best of Both)

1. Generate identity with LLM (DeepSeek/Gemini)
2. Use LLM to pick traits from taxonomy
3. Compose SVG on-chain from traits
4. Store as data URI

**This is what I recommend for TU1.**

---

## C64 Color Palette (Reference)

```
0x00 #000000  Black        0x9F #9F4E44  Red
0x62 #626262  Dark Gray    0xCB #CB7E75  Light Red
0x89 #898989  Gray         0x6D #6D5412  Brown
0xAD #ADADAD  Light Gray   0xA1 #A1683C  Orange
0xFF #FFFFFF  White        0xC9 #C9D487  Yellow
0x9A #9AE29B  Light Green  0x5C #5CAB5E  Green
0x6A #6ABFC6  Cyan         0x88 #887ECB  Purple
0x50 #50459B  Dark Purple  0xA0 #A057A3  Magenta
```

---

## SVG Template (64×64 Pixel Art)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" 
     shape-rendering="crispEdges">
  <!-- Background -->
  <rect fill="#000000" width="64" height="64"/>
  
  <!-- Background pattern -->
  <path stroke="#50459B" d="M0 0h64M0 63h64M0 0v64M63 0v64"/>
  
  <!-- Creature body -->
  <path fill="#6ABFC6" d="M20 20h24v24H20z"/>
  
  <!-- Creature face -->
  <path fill="#FFFFFF" d="M24 28h4v4h-4zM36 28h4v4h-4z"/>
  <path fill="#000000" d="M26 30h1v1h-1zM37 30h1v1h-1z"/>
  
  <!-- Name tag -->
  <text x="32" y="56" text-anchor="middle" 
        fill="#FFFFFF" font-size="4" font-family="monospace">
    AGENT #42
  </text>
</svg>
```

---

## Recommended Approach for TU1

```
┌─────────────────────────────────────────────────────────────┐
│  TU1 HYBRID PIPELINE                                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. User mints TU1 → gets NFT (via DN-404)                  │
│                                                              │
│  2. Token ID → hash → select traits                          │
│     token ID 42 → background: neon_grid                      │
│                   creature: robot                             │
│                   accessory: crown                            │
│                                                              │
│  3. LLM generates identity JSON                              │
│     { name: "QBIT", description: "...",                     │
│       skills: ["analysis", "riddles"] }                      │
│                                                              │
│  4. On-chain SVG composed from traits                        │
│     background + creature + accessories + name tag           │
│                                                              │
│  5. tokenURI = data:image/svg+xml;base64,<svg>              │
│     Stored in ERC-8004 registry                              │
│                                                              │
│  COST: ~$0 per NFT (gas only on Base)                       │
└─────────────────────────────────────────────────────────────┘
```
