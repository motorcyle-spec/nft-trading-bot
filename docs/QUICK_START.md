# Quick Reference Guide

## 📦 What's Where

This is a **Yarn workspaces monorepo** for the NFT Trading Bot System. Everything is organized for efficient development.

### Core Packages
- **`/contracts`** - Smart contracts (Solidity + Foundry)
- **`/frontend`** - React app (Vite + TypeScript)
- **`/backend`** - Node.js services (Redis, WebSockets, IPFS)
- **`/subgraph`** - The Graph indexing (GraphQL)

### Documentation
All docs live in `/docs/`:
- **REPO_STRUCTURE.md** ← Start here! Full directory guide
- **ARCHITECTURE.md** - System design (7 layers)
- **MONOREPO.md** - Workspace configuration
- **project-bible.md** - Complete tech spec
- **FOUNDRY_GUIDE.md** - Smart contracts setup
- Others: threat-model, risk-assessment, audit-checklist

### Scripts
- **`scripts/deploy-all.sh`** - Deploy everything
- **`scripts/test-all.sh`** - Run all tests
- **`scripts/gas-optimize.py`** - Gas analysis

---

## ⚡ Quick Commands

```bash
# Setup
yarn install

# Build all packages
yarn build

# Test all packages
yarn test

# Test specific workspace
yarn workspace contracts test
yarn workspace frontend test

# Run development
yarn dev              # All workspaces in watch mode
yarn dev:contracts   # Just contracts
yarn dev:frontend    # Just frontend
yarn dev:backend     # Just backend

# Deploy
yarn deploy           # Full deployment
yarn deploy:contracts:sepolia  # Just contracts to Sepolia
```

---

## 🎯 Common Tasks

### Smart Contracts
```bash
cd contracts
forge build          # Compile
forge test           # Run tests
forge test --gas-report  # With gas analysis
forge fmt            # Format code
```

### Frontend Development
```bash
yarn workspace frontend dev    # Start dev server (http://localhost:5173)
yarn workspace frontend build  # Production build
yarn workspace frontend test   # Run tests
```

### Backend Services
```bash
yarn workspace backend dev     # Start backend
yarn workspace backend test    # Run tests
```

### The Graph
```bash
yarn workspace subgraph codegen    # Generate types from schema
yarn workspace subgraph build      # Build subgraph
```

---

## 📚 Documentation Map

| Want to... | Read this |
|------------|-----------|
| Understand the architecture | `ARCHITECTURE.md` |
| Set up workspaces | `MONOREPO.md` |
| Develop smart contracts | `FOUNDRY_GUIDE.md` |
| Understand imports/remappings | `REMAPPINGS_GUIDE.md` |
| Full technical specification | `project-bible.md` |
| Security threats | `threat-model.md` |
| Risk analysis | `risk-assessment.md` |
| Security checklist | `audit-checklist.md` |
| Repository layout | `REPO_STRUCTURE.md` |

---

## 🔍 Finding Files

```
contracts/src/          → Smart contract code
frontend/src/           → React components & pages
backend/src/            → Node.js server code
subgraph/src/           → The Graph mappings
tests/e2e/              → End-to-end tests
docs/                   → All documentation
scripts/                → Deployment & utility scripts
.github/workflows/      → CI/CD pipelines
```

---

## 🚀 Getting Started

1. **Clone & Install**
   ```bash
   git clone <repo>
   cd nft-trading-bot-system
   yarn install
   ```

2. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your RPC URLs, API keys, etc.
   ```

3. **Build Everything**
   ```bash
   yarn build
   ```

4. **Run Tests**
   ```bash
   yarn test
   ```

5. **Deploy** (see MONOREPO.md for detailed steps)
   ```bash
   yarn deploy
   ```

---

## ❓ Help & Support

- **Stuck?** Check `/docs/REPO_STRUCTURE.md` for detailed file locations
- **Smart contracts?** See `/docs/FOUNDRY_GUIDE.md`
- **Architecture?** See `/docs/ARCHITECTURE.md`
- **Security concerns?** See `/docs/threat-model.md` or `/docs/audit-checklist.md`
- **Complete spec?** See `/docs/project-bible.md`

---

**Last Updated:** January 7, 2026  
**Version:** 1.0.0 (Consolidated & Organized)
