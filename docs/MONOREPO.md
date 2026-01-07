# Monorepo Structure & Yarn Workspaces Configuration

## Overview

The NFT Trading Bot System uses a **Yarn Workspaces monorepo** to manage four independent packages:

```
nft-trading-bot-system/
├── package.json                 (root monorepo configuration)
├── .env.example                (shared environment template)
├── .gitignore                  (monorepo-wide ignore patterns)
├── contracts/                  (Solidity smart contracts)
│   ├── package.json
│   ├── src/
│   ├── test/
│   └── forge.toml
├── frontend/                   (React + Vite)
│   ├── package.json
│   ├── src/
│   └── vite.config.ts
├── backend/                    (Node.js + Express)
│   ├── package.json
│   ├── src/
│   └── tsconfig.json
├── subgraph/                   (The Graph)
│   ├── package.json
│   ├── src/
│   └── subgraph.yaml
└── docs/                       (documentation)
    └── README.md
```

## Workspace Configuration

### Root `package.json` Workspace Definition

```json
{
  "private": true,
  "workspaces": [
    "contracts",
    "frontend",
    "backend",
    "subgraph"
  ]
}
```

**Key Points:**

- **`"private": true`** - Marks root as a private monorepo (prevents accidental publishing to npm)
- **`"workspaces"`** - Array of workspace directories
- Each workspace must have its own `package.json`

### Workspace Package Structure

Each workspace should follow this pattern:

```json
{
  "name": "@nft-trading-bot/contracts",
  "version": "0.1.0",
  "description": "Smart contracts for NFT Trading Bot",
  "private": true,
  "scripts": {
    "build": "forge build",
    "test": "forge test",
    "deploy": "forge script DeploymentScript --broadcast"
  },
  "dependencies": {},
  "devDependencies": {}
}
```

## Installation & Setup

### Initial Setup

```bash
# Clone repository
git clone https://github.com/yourusername/nft-trading-bot-system.git
cd nft-trading-bot-system

# Install all workspace dependencies at once
yarn install

# Install Git hooks for pre-commit linting
yarn prepare
```

**What `yarn install` does in a monorepo:**

1. Installs root `devDependencies` (ESLint, Prettier, etc.)
2. Installs each workspace's `package.json` dependencies
3. Creates a single `node_modules/` at root (symlinked to workspaces)
4. Deduplicates common dependencies across workspaces

### Clean Installation

```bash
# Remove all node_modules and cache
yarn clean

# Reinstall from scratch
yarn install
```

## Working with Workspaces

### Running Scripts in a Specific Workspace

```bash
# Run build script only in contracts workspace
yarn workspace contracts build

# Run test script in frontend workspace
yarn workspace frontend test

# Run dev in backend workspace
yarn workspace backend dev
```

### Running Scripts in All Workspaces

```bash
# Run build script in all workspaces (in parallel)
yarn workspaces foreach --parallel run build

# Run test script in all workspaces (sequential)
yarn workspaces foreach run test

# Run with verbose output
yarn workspaces foreach --verbose run build
```

### Installing Dependencies in a Workspace

```bash
# Add lodash to contracts workspace
yarn workspace contracts add lodash

# Add viem as dev dependency to frontend
yarn workspace frontend add -D viem

# Install globally in all workspaces
yarn workspaces foreach run add lodash
```

### Removing Dependencies

```bash
# Remove from specific workspace
yarn workspace frontend remove react-dom

# Remove from root
yarn remove eslint
```

## Available Scripts

### Build Commands

```bash
# Build all packages in optimal order
yarn build

# Build specific packages
yarn build:contracts
yarn build:frontend
yarn build:backend
yarn build:subgraph

# Build with specific order (respecting dependencies)
yarn build:all
```

### Development Commands

```bash
# Start development mode for all packages
yarn dev

# Start specific workspace in dev mode
yarn dev:contracts
yarn dev:frontend
yarn dev:backend
```

### Testing Commands

```bash
# Run all tests
yarn test

# Run tests in specific workspace
yarn test:contracts
yarn test:frontend
yarn test:backend

# Run Solidity contract tests with coverage
yarn test:contracts:coverage

# Run frontend E2E tests
yarn test:frontend:e2e

# Run integration tests (contracts + frontend)
yarn test:integration
```

### Linting & Formatting

```bash
# Lint all packages
yarn lint

# Format all code
yarn format

# Check formatting without modifying
yarn format:check

# Lint specific workspace
yarn lint:contracts
```

### Deployment Commands

```bash
# Deploy entire system
yarn deploy

# Deploy specific components
yarn deploy:contracts:sepolia
yarn deploy:contracts:mainnet
yarn deploy:frontend
yarn deploy:backend
yarn deploy:subgraph
```

### CI/CD Commands

```bash
# Build and test (for CI pipeline)
yarn ci:all

# Just build
yarn ci:build

# Just lint
yarn ci:lint

# Just test
yarn ci:test
```

## Dependency Resolution in Monorepos

### Deduplication Strategy

**Yarn automatically deduplicates** common dependencies across workspaces:

```
Root:
├── node_modules/
│   ├── typescript/ (shared by all workspaces)
│   ├── eslint/
│   └── prettier/
└── workspaces/
    ├── contracts/node_modules/ (symlink to root)
    ├── frontend/node_modules/ (symlink to root)
    ├── backend/node_modules/ (symlink to root)
    └── subgraph/node_modules/ (symlink to root)
```

**Benefits:**
- ✅ Reduces disk space (no duplication)
- ✅ Faster installation
- ✅ Consistent versions across projects

**Potential Issues:**
- ❌ Version conflicts if workspaces need different versions
- ❌ Hidden dependencies on root `node_modules`

### Resolving Version Conflicts

**Problem:** Contracts need TypeScript 5.0, Backend needs 5.3

**Solution 1: Use Resolutions (Force Single Version)**
```json
{
  "resolutions": {
    "typescript": "^5.3.3"
  }
}
```

**Solution 2: Workspace-Specific Versions**
```json
{
  "workspaces": {
    "contracts": {
      "typescript": "^5.0.0"
    },
    "backend": {
      "typescript": "^5.3.3"
    }
  }
}
```

**Solution 3: Hoist to Root**
```json
{
  "workspaces": {
    "nohoist": [
      "**/node_modules/some-package"
    ]
  }
}
```

## Inter-Workspace Dependencies

### Referencing Another Workspace

**Frontend depends on Contract ABI generation:**

```json
{
  "name": "@nft-trading-bot/frontend",
  "dependencies": {
    "@nft-trading-bot/contracts": "workspace:*"
  }
}
```

**In code:**
```typescript
import { BotFactory_ABI } from '@nft-trading-bot/contracts';
```

### Workspace Package Publishing

When publishing to npm:
```json
{
  "name": "@nft-trading-bot/contracts",
  "publishConfig": {
    "access": "public"
  },
  "files": [
    "out/",
    "README.md"
  ]
}
```

## Performance Optimization

### Parallel Execution

```bash
# Run all builds in parallel (faster)
yarn workspaces foreach --parallel run build

# Sequential execution (safer for CI)
yarn workspaces foreach run build
```

### Topological Order

```bash
# Respects dependency order (backend before frontend)
yarn workspaces foreach --topological run build
```

### Filtering Workspaces

```bash
# Run in contracts and frontend only
yarn workspaces foreach --only '{contracts,frontend}' run build

# Exclude subgraph
yarn workspaces foreach --exclude subgraph run build
```

## Troubleshooting

### Problem: "Cannot find module '@nft-trading-bot/contracts'"

**Causes:**
- Workspace not built yet
- Wrong import path
- Package.json name doesn't match import

**Solution:**
```bash
# Ensure workspace is built
yarn workspace contracts build

# Check package.json name
cat contracts/package.json | grep name

# Verify symlinks
ls -la node_modules/@nft-trading-bot/
```

### Problem: "Version conflicts after `yarn install`"

**Solution:**
```bash
# Clean and reinstall
yarn clean
yarn install

# Check yarn resolution
yarn workspaces foreach run list typescript
```

### Problem: Different Workspace Versions

**Example:** Contract tests use Hardhat v2.14, but Backend uses v2.17

**Solution:**
```bash
# Add to root resolutions
"resolutions": {
  "hardhat": "^2.17.0"
}

# Or allow per-workspace versions
yarn workspace contracts add -D hardhat@^2.14.0
```

### Problem: Slow Installation

**Solutions:**
```bash
# Use network concurrency
yarn install --network-concurrency 8

# Skip optional dependencies
yarn install --ignore-optional

# Use offline cache (if available)
yarn install --offline
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'yarn'
      
      - run: yarn install --frozen-lockfile
      - run: yarn ci:build
      - run: yarn ci:lint
      - run: yarn ci:test
```

### Docker Multi-Stage Build

```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build:all

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/frontend/dist ./frontend/dist
COPY --from=builder /app/backend/dist ./backend/dist
CMD ["yarn", "deploy:frontend"]
```

## Best Practices

### 1. Keep Root Dependencies Minimal
Only include truly global tools:
- ✅ ESLint, Prettier (shared config)
- ✅ TypeScript (shared for type checking)
- ❌ React (workspace-specific)
- ❌ Solidity libraries (workspace-specific)

### 2. Clear Workspace Names
```json
{
  "name": "@nft-trading-bot/contracts",
  "name": "@nft-trading-bot/frontend",
  "name": "@nft-trading-bot/backend",
  "name": "@nft-trading-bot/subgraph"
}
```

### 3. Consistent Scripts
All workspaces should have:
```json
{
  "scripts": {
    "build": "...",
    "dev": "...",
    "test": "...",
    "lint": "...",
    "format": "..."
  }
}
```

### 4. Document Dependencies
```json
{
  "description": "Smart contracts: depends on contracts built before frontend"
}
```

### 5. Use Resolutions Sparingly
```json
{
  "resolutions": {
    "typescript": "^5.3.3"
  }
}
```

### 6. Lock File Management
```bash
# Always commit yarn.lock
git add yarn.lock

# Frozen installs in CI
yarn install --frozen-lockfile
```

## Migration from Other Package Managers

### From NPM Monorepo
```bash
# Migrate from npm workspaces to Yarn
rm package-lock.json
yarn install
```

### From PNPM Monorepo
```bash
# Migrate from pnpm to Yarn
rm pnpm-lock.yaml
yarn install
```

## Additional Resources

- [Yarn Workspaces Documentation](https://classic.yarnpkg.com/en/docs/workspaces/)
- [Yarn 3+ Workspaces](https://yarnpkg.com/features/workspaces)
- [Monorepo Best Practices](https://www.toptal.com/front-end/guide-to-monorepos)
- [Turborepo Documentation](https://turbo.build/repo/docs) (alternative monorepo tool)

---

**Last Updated:** January 2026
