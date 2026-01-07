# Repository Structure Guide

## Overview

This repository is a **Yarn workspaces monorepo** for the **NFT Trading Bot System** - an autonomous, NFT-based trading bot factory where each bot is represented as an ERC-721 token with its own secure wallet infrastructure.

**Key accomplishments:**
- ✅ Consolidated all packages to root level
- ✅ Centralized documentation in `/docs`
- ✅ Unified workspace configuration in root `package.json`
- ✅ Removed nested redundant folders

---

## Directory Structure

```
nft-trading-bot-system/
├── .github/                    # GitHub Actions CI/CD workflows
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore patterns
├── README.md                  # Main project documentation
├── package.json               # Root monorepo configuration (Yarn workspaces)
├── yarn.lock                  # Dependency lock file
│
├── contracts/                 # 🔗 Smart Contracts Workspace
│   ├── package.json          # Workspace configuration
│   ├── foundry.toml          # Forge build configuration
│   ├── remappings.txt        # Solidity import remappings
│   ├── src/                  # Smart contract source code
│   │   ├── BotFactory.sol    # Factory for deploying bots
│   │   ├── BotNFT.sol        # ERC-721 NFT implementation
│   │   ├── BotRegistry.sol   # Bot → TokenID registry
│   │   ├── BotProxy.sol      # EIP-1167 minimal proxy
│   │   ├── BotWallet.sol     # Gnosis Safe-based wallet
│   │   ├── TradingBot.sol    # Core trading logic
│   │   ├── interfaces/       # Smart contract interfaces
│   │   └── utils/            # Helper contracts & libraries
│   ├── script/               # Deployment scripts
│   │   └── DeployBotFactory.s.sol  # Main deployment
│   ├── test/                 # Forge tests
│   │   ├── BotFactory.t.sol
│   │   ├── BotNFT.t.sol
│   │   ├── TradingBot.t.sol
│   │   └── fuzz/            # Fuzzing tests
│   └── lib/                  # Forge dependencies (foundry-rs)
│
├── frontend/                  # 🎨 React Frontend Workspace
│   ├── package.json          # Workspace configuration
│   ├── vite.config.ts        # Vite build configuration
│   ├── tsconfig.json         # TypeScript configuration
│   ├── public/               # Static assets
│   │   └── index.html        # Entry HTML
│   └── src/                  # React source code
│       ├── App.tsx           # Main app component
│       ├── main.tsx          # Entry point
│       ├── index.css         # Global styles
│       ├── components/       # React components
│       │   ├── BotCreationForm.tsx
│       │   ├── PerformanceChart.tsx
│       │   └── PortfolioView.tsx
│       ├── hooks/            # Custom React hooks
│       ├── stores/           # Zustand state management
│       │   └── botStore.ts
│       ├── types/            # TypeScript type definitions
│       │   └── index.ts
│       └── utils/            # Utility functions
│
├── backend/                   # 🔧 Node.js Backend Workspace
│   ├── package.json          # Workspace configuration
│   └── src/                  # Backend source code
│       ├── config/           # Configuration files
│       ├── cache.ts          # Redis caching layer
│       ├── streams.ts        # WebSocket streams (QuickNode)
│       ├── ipfs-pinner.ts   # IPFS pinning (Pinata)
│       └── sentry.ts         # Error tracking & monitoring
│
├── subgraph/                  # 📊 The Graph Indexing Workspace
│   ├── package.json          # Workspace configuration
│   ├── subgraph.yaml         # Subgraph manifest
│   ├── schema.graphql        # GraphQL schema definitions
│   └── src/                  # Subgraph mapping handlers
│       ├── bot-factory.ts    # Factory event handlers
│       └── trading-bot.ts    # Trade event handlers
│
├── scripts/                   # 📝 Deployment & Utility Scripts
│   ├── deploy-all.sh         # One-command deployment
│   ├── test-all.sh          # Run all tests
│   └── gas-optimize.py      # Gas optimization analysis
│
├── tests/                     # 🧪 Integration Tests
│   └── e2e/                  # End-to-end tests
│
└── docs/                      # 📚 Comprehensive Documentation
    ├── README.md            # Documentation index
    ├── ARCHITECTURE.md      # High-level system architecture
    ├── MONOREPO.md         # Monorepo structure & setup guide
    ├── FOUNDRY_GUIDE.md    # Smart contract setup & testing
    ├── REMAPPINGS_GUIDE.md # Solidity import configuration
    ├── project-bible.md    # Complete technical specification
    ├── threat-model.md     # Security threat analysis
    ├── risk-assessment.md  # Risk quantification & mitigation
    ├── audit-checklist.md  # 80+ security verification items
    └── flowchart.mmd       # System architecture diagram (Mermaid)
```

---

## Workspace Packages

The monorepo includes **4 independent Yarn workspaces**, each with its own dependencies and build pipeline:

### 1. **contracts** - Smart Contracts
- **Language:** Solidity (^0.8.23)
- **Framework:** Foundry (Forge)
- **Key Contracts:** BotFactory, BotNFT, TradingBot, BotWallet, BotRegistry, BotProxy
- **Tests:** Forge-based unit tests + fuzzing tests
- **Deploy:** Forge scripts (Sepolia, Mainnet)

### 2. **frontend** - React Application
- **Language:** TypeScript + TSX
- **Framework:** React 18 + Vite
- **UI:** Shadcn/UI + TailwindCSS
- **Web3:** Wagmi v2 + Viem + RainbowKit
- **State:** Zustand
- **Charts:** Recharts
- **Dev Server:** `yarn workspace frontend dev`
- **Build:** `yarn workspace frontend build`

### 3. **backend** - Node.js Services
- **Language:** TypeScript
- **Runtime:** Node.js (>=18.0.0)
- **Services:**
  - Redis caching for bot state
  - QuickNode WebSocket for real-time updates
  - Pinata IPFS integration for metadata
  - Sentry error tracking

### 4. **subgraph** - The Graph Indexing
- **Language:** TypeScript (with GraphQL)
- **Framework:** The Graph
- **Entities:** Bot, Trade, Owner
- **Events:** BotDeployed, TradeExecuted
- **API:** GraphQL queries for bot data

---

## Key Features of This Organization

### ✨ Monorepo Benefits
- **Single workspace:** One `yarn install` installs all dependencies
- **Unified scripts:** Root `package.json` provides workspace shortcuts
- **Shared dev tools:** ESLint, Prettier, TypeScript at root level
- **Efficient CI/CD:** GitHub Actions run tests & deployments seamlessly

### 🔗 Workspace Commands
```bash
# Run scripts in all workspaces
yarn build              # Build all packages
yarn test              # Test all packages
yarn lint              # Lint all packages

# Run scripts in specific workspace
yarn workspace contracts build
yarn workspace frontend dev
yarn workspace backend test

# List all workspaces
yarn workspaces list
```

### 📚 Documentation Organization
All project documentation is centralized in `/docs/`:
- **ARCHITECTURE.md** - System design overview (7 layers)
- **MONOREPO.md** - Workspace setup & configuration
- **FOUNDRY_GUIDE.md** - Smart contract development
- **REMAPPINGS_GUIDE.md** - Solidity import paths
- **project-bible.md** - Complete technical specification
- **threat-model.md** - Security analysis
- **risk-assessment.md** - Risk evaluation
- **audit-checklist.md** - 80+ security checks
- **flowchart.mmd** - Architecture diagram

---

## Root Configuration Files

### `package.json` (Root)
- Workspace declarations
- Shared dev dependencies (ESLint, Prettier, TypeScript)
- Root-level scripts for building, testing, deploying
- Pre-commit hooks (Husky, lint-staged)
- CommitLint configuration

### `yarn.lock`
- Ensures consistent dependency versions across all workspaces
- Commit to repository for reproducible installs

### `.env.example`
- Template for environment variables
- Copy to `.env` and configure with actual values

### `.gitignore`
- Standard patterns for Node.js + Solidity projects
- Excludes compiled artifacts, build outputs, secrets

---

## Common Workflows

### 🏗️ Development Setup
```bash
# Clone and install
git clone <repo>
cd nft-trading-bot-system
yarn install

# Set up environment
cp .env.example .env
# Edit .env with your configuration
```

### 🧪 Testing
```bash
# Test all workspaces
yarn test

# Test specific workspace
yarn workspace contracts test
yarn workspace frontend test

# Smart contract testing with gas report
yarn workspace contracts test:gas

# Coverage report
yarn workspace contracts test:coverage
```

### 🏗️ Building
```bash
# Build all packages
yarn build

# Build specific workspace
yarn workspace contracts build
yarn workspace frontend build

# Build and watch
yarn dev
```

### 🚀 Deployment
```bash
# One-command deployment
yarn deploy

# Deploy specific components
yarn deploy:contracts:sepolia
yarn deploy:frontend
yarn deploy:subgraph
```

---

## Migration Summary

This consolidated structure replaces the previous nested organization where `nft-trading-bot-system/` was a nested folder. Now:

| Before | After |
|--------|-------|
| `nft-trading-bot-system/contracts/` | `contracts/` |
| `nft-trading-bot-system/frontend/` | `frontend/` |
| `nft-trading-bot-system/backend/` | `backend/` |
| `nft-trading-bot-system/subgraph/` | `subgraph/` |
| `nft-trading-bot-system/docs/` | `docs/` |
| Root `.env.example` | `docs/` moves to root |
| Multiple doc locations | All consolidated in `docs/` |

**Result:** Cleaner root structure, easier navigation, unified monorepo setup.

---

## Getting Started

1. **Setup:** `yarn install`
2. **Configuration:** `cp .env.example .env` → Edit with your values
3. **Build:** `yarn build`
4. **Test:** `yarn test`
5. **Deploy:** `yarn deploy` or `bash scripts/deploy-all.sh`

For detailed instructions, see the documentation in `/docs/`.
