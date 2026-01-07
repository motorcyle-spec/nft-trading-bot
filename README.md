# NFT Trading Bot System 🤖

An autonomous NFT-based trading bot factory system where each trading bot is represented as an ERC-721 token with its own secure wallet infrastructure. Bots operate independently on Uniswap V3, executing programmed strategies while ownership and control are managed through transferable NFTs with complete state preservation.

> **📋 New to this project?** Start with [QUICK_START.md](QUICK_START.md) for essential commands and file locations.

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Building & Deployment](#building--deployment)
- [Running the System](#running-the-system)
- [Testing](#testing)
- [Edge Cases & Troubleshooting](#edge-cases--troubleshooting)
- [Security Best Practices](#security-best-practices)
- [Scalability & Mainnet Migration](#scalability--mainnet-migration)
- [Contributing](#contributing)
- [License](#license)

## Overview

### What is the NFT Trading Bot System?

The NFT Trading Bot System creates a marketplace for autonomous trading bots where:

- **Each bot is an NFT** - ERC-721 token represents complete ownership
- **Bots own wallets** - Each bot controls a dedicated smart contract wallet (Gnosis Safe)
- **Autonomous trading** - Bots execute trading strategies on Uniswap V3 without manual intervention
- **Full transferability** - NFT sales include the bot, wallet, funds, and trading history
- **State preservation** - Performance metrics and configuration transfer with ownership

This enables a new paradigm: programmable, transferable, autonomous trading agents that can be bought, sold, and owned on decentralized marketplaces like OpenSea.

### Key Innovations

| Feature | Impact |
|---------|--------|
| **Composable Ownership** | NFT → Bot → Wallet creates clear ownership chain |
| **Gas Optimized** | Minimal proxy pattern reduces deployment costs by ~10x |
| **Secure by Design** | CREATE2 with sender-based salts prevents frontrunning |
| **Market Ready** | Native OpenSea integration with rich metadata |
| **Battle Tested** | Uses proven patterns (ERC-721A, Gnosis Safe, Uniswap V3) |

## Core Features

✅ **Autonomous Trading** - Bots execute strategies without human intervention  
✅ **NFT-Based Ownership** - Trade bots like digital assets  
✅ **State Preservation** - Performance history travels with the bot  
✅ **Secure Wallets** - Each bot controls a Gnosis Safe multi-sig wallet  
✅ **Uniswap V3 Integration** - Advanced liquidity provision and trading  
✅ **Gas Optimized** - EIP-1167 minimal proxies for cost efficiency  
✅ **Real-time Dashboard** - WebSocket updates via Quicknode Streams  
✅ **Subgraph Indexing** - Efficient querying via The Graph protocol  

## Architecture

The system is built on **8 distinct layers**, each with specific responsibilities:

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: User Interaction                               │
│ (React Frontend, Wallet Connections, Dashboard)         │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 2: Factory & Deployment                           │
│ (BotFactory, Bot Registry, Deterministic Addressing)    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 3: Bot Instance                                   │
│ (EIP-1167 Proxy, Access Control, Strategy Execution)    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 4: Wallet Management                              │
│ (Gnosis Safe Integration, Fund Management)              │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 5: Strategy Execution                             │
│ (Uniswap V3, Trade Routing, Order Fulfillment)          │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 6: Indexing & Analytics                           │
│ (The Graph Subgraph, Real-time Metrics)                 │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 7: Backend Services                               │
│ (Redis Cache, WebSocket Server, API Gateway)            │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ Layer 8: Secondary Market                               │
│ (OpenSea Integration, NFT Trading, Marketplace)         │
└─────────────────────────────────────────────────────────┘
```

See [architecture-diagram.png](docs/architecture-diagram.png) for a detailed visual representation.

### Layer Descriptions

- **Layer 1: User Interaction** - Web interface for bot creation, management, and monitoring
- **Layer 2: Factory & Deployment** - Secure bot creation with deterministic addressing
- **Layer 3: Bot Instance** - Individual bot logic with access control and strategy execution
- **Layer 4: Wallet Management** - Gnosis Safe integration for secure fund management
- **Layer 5: Strategy Execution** - Uniswap V3 trading and order fulfillment
- **Layer 6: Indexing & Analytics** - The Graph subgraph for efficient querying
- **Layer 7: Backend Services** - Redis cache, WebSockets, and API gateway
- **Layer 8: Secondary Market** - OpenSea and decentralized trading platforms

## Prerequisites

Before setting up the project, ensure you have the following installed:

### Required Tools

- **Node.js** (v18.0.0 or higher)  
  [Download Node.js](https://nodejs.org/)

- **Yarn** (v3.6.0 or higher)  
  ```bash
  npm install -g yarn
  ```

- **Foundry** (Forge, Cast, Anvil)  
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```

- **Git** (v2.30.0 or higher)  
  [Download Git](https://git-scm.com/)

### Required Accounts & API Keys

- **Ethereum Sepolia Testnet account** with test ETH
- **QuickNode API key** for RPC access
- **Pinata API key** for IPFS integration
- **GitHub account** (for repository access)

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/nft-trading-bot-system.git
cd nft-trading-bot-system
```

### Step 2: Install Dependencies

Install both backend (contracts) and frontend dependencies:

```bash
# Install all dependencies
yarn install

# Or install separately
cd contracts && yarn install
cd ../frontend && yarn install
cd ../backend && yarn install
```

### Step 3: Verify Installation

```bash
# Check Node.js version
node --version  # Should be v18.0.0+

# Check Yarn version
yarn --version  # Should be v3.6.0+

# Check Foundry
forge --version
cast --version
anvil --version
```

## Configuration

### Step 1: Create Environment Files

Create `.env` files in the root and subdirectories:

#### Root `.env`
```bash
# Never commit this file!
NODE_ENV=development
NETWORK=sepolia
```

#### `contracts/.env` (Smart Contracts)
```bash
# RPC Configuration
QUICKNODE_RPC_URL=https://sepolia.quicknode.pro/your-api-key
ETHERSCAN_API_KEY=your_etherscan_api_key

# Deployment Accounts
DEPLOYER_PRIVATE_KEY=your_private_key_here
DEPLOYER_ADDRESS=your_wallet_address

# Contract Configuration
INITIAL_STRATEGY_FEE=500  # 5% fee (in basis points)
GAS_PRICE_LIMIT=100  # Max gas price in gwei
```

#### `frontend/.env.local` (React Frontend)
```bash
VITE_RPC_URL=https://sepolia.quicknode.pro/your-api-key
VITE_CHAIN_ID=11155111  # Sepolia
VITE_API_URL=http://localhost:3000/api
VITE_WEBSOCKET_URL=ws://localhost:3000
VITE_BOT_FACTORY_ADDRESS=0x...
VITE_NFT_ADDRESS=0x...
```

#### `backend/.env` (Node.js Backend)
```bash
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug

# Database
REDIS_URL=redis://localhost:6379

# IPFS / Pinata
PINATA_API_KEY=your_pinata_api_key
PINATA_API_SECRET=your_pinata_api_secret

# The Graph
SUBGRAPH_URL=http://localhost:8000/subgraphs/name/your-username/nft-trading-bot

# RPC Provider
QUICKNODE_RPC_URL=https://sepolia.quicknode.pro/your-api-key
QUICKNODE_WS_URL=wss://sepolia-ws.quicknode.pro/your-api-key

# Blockchain Monitoring
CONTRACT_ADDRESSES=0x...,0x...
POLLING_INTERVAL=5000
```

### Step 2: Sepolia Testnet Setup

1. **Get Sepolia ETH** from a testnet faucet:
   - [QuickNode Faucet](https://faucet.quicknode.pro/)
   - [Infura Faucet](https://www.infura.io/faucet/sepolia)
   - [Alchemy Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)

2. **Get test tokens** (USDC, WETH):
   ```bash
   # Use the QuickNode faucet or deploy test token contracts
   # Instructions in docs/TESTNET_SETUP.md
   ```

3. **Verify connection**:
   ```bash
   cast client-version --rpc-url $QUICKNODE_RPC_URL
   cast balance <YOUR_ADDRESS> --rpc-url $QUICKNODE_RPC_URL
   ```

## Building & Deployment

### Step 1: Build Smart Contracts

```bash
cd contracts

# Compile contracts
forge build

# Check contract sizes
forge build --sizes

# Run static analysis
forge fmt --check
```

### Step 2: Deploy to Sepolia Testnet

```bash
cd contracts

# Deploy using Foundry scripts
forge script script/DeployNFTTradingBot.s.sol:DeploymentScript \
  --rpc-url $QUICKNODE_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY

# Or use dry-run first
forge script script/DeployNFTTradingBot.s.sol:DeploymentScript \
  --rpc-url $QUICKNODE_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --gas-estimate-multiplier 150
```

### Step 3: Build Frontend

```bash
cd frontend

# Build for production
yarn build

# Or build for development with hot reload
yarn dev
```

### Step 4: Build Backend Services

```bash
cd backend

# Install dependencies
yarn install

# Build TypeScript
yarn build

# Run migrations (if using a database)
yarn migrate
```

## Running the System

### Option A: Local Development (Recommended)

#### Terminal 1: Smart Contract Testing
```bash
cd contracts
forge test --watch
```

#### Terminal 2: Local Blockchain (Anvil)
```bash
anvil --fork-url $QUICKNODE_RPC_URL --fork-block-number latest
```

#### Terminal 3: Backend Services
```bash
cd backend
yarn dev
```

#### Terminal 4: Frontend Development Server
```bash
cd frontend
yarn dev
```

#### Terminal 5: The Graph Subgraph (Optional)
```bash
cd subgraph
yarn codegen
yarn build
yarn deploy-local
```

#### Terminal 6: Redis Cache
```bash
redis-server
```

### Option B: Docker Compose (Coming Soon)
```bash
docker-compose up -d
```

### Accessing the Application

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Subgraph Playground**: http://localhost:8000
- **Redis CLI**: `redis-cli`

## Testing

### Smart Contract Tests

```bash
cd contracts

# Run all tests
forge test

# Run specific test file
forge test --match-path test/BotFactory.t.sol

# Run specific test
forge test --match-contract BotFactoryTest --match-function testDeploy

# Run with coverage
forge coverage

# View detailed gas reports
forge test --gas-report
```

## CI / Fuzz Annotations

To have the PR fuzz job automatically post a comment linking to the uploaded fuzz artifact when a PR-targeted fuzz run fails, set the repository secret `PR_FUZZ_ANNOTATE` to `true` (a string). When enabled, the workflow will post a PR comment with a link to the run artifacts page and the `pr-fuzz-report` artifact name.

Note: the workflow sets the job permission `issues: write` to allow posting comments with the `GITHUB_TOKEN`.

### Frontend E2E Tests

```bash
cd frontend

# Run Cypress E2E tests
yarn test:e2e

# Run with UI
yarn test:e2e:ui

# Run specific test
yarn test:e2e -- --spec cypress/e2e/bot-creation.cy.ts
```

### Backend API Tests

```bash
cd backend

# Run Jest unit tests
yarn test

# Run with coverage
yarn test --coverage

# Run in watch mode
yarn test --watch
```

### Integration Tests

```bash
cd tests

# Run full integration tests
yarn test:integration

# With custom gas price limit
GAS_LIMIT=5000000 yarn test:integration
```

## Edge Cases & Troubleshooting

### Common Issues & Solutions

#### **Issue: Wallet Connection Fails**
```
Error: User rejected wallet connection
```
**Solution:**
- Ensure wallet is set to Sepolia testnet
- Verify `VITE_CHAIN_ID=11155111` in frontend `.env`
- Check that RPC endpoint is accessible:
  ```bash
  curl -X POST $QUICKNODE_RPC_URL \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
  ```

#### **Issue: Insufficient Test ETH**
```
Error: Insufficient balance for transaction
```
**Solution:**
- Use Sepolia faucets (linked above)
- For large deployments, use Testnet Bridge
- Request test tokens from the team

#### **Issue: Subgraph Indexing Delay**
```
Warning: Pending transaction not indexed yet
```
**Solution:**
- Wait 15-30 seconds for indexing
- Check subgraph health: `curl http://localhost:8000/graphql`
- Verify event emissions in transaction receipt
- Restart graph node: `docker restart graph-node`

#### **Issue: Gas Price Too High**
```
Error: Transaction fee exceeds limit
```
**Solution:**
- Check current gas prices: `cast gas-price --rpc-url $QUICKNODE_RPC_URL`
- Adjust `GAS_PRICE_LIMIT` in `.env`
- Wait for network congestion to decrease
- Use priority fee multiplier:
  ```bash
  forge script ... --gas-price 1000000000  # 1 gwei
  ```

#### **Issue: CREATE2 Salt Collision**
```
Error: Bot address already exists
```
**Solution:**
- Use unique user salt in bot creation
- Check existing bots: `cast call $FACTORY_ADDRESS "bots(uint256)" 0`
- Increment salt parameter

#### **Issue: Redis Connection Refused**
```
Error: connect ECONNREFUSED 127.0.0.1:6379
```
**Solution:**
- Ensure Redis is running: `redis-server`
- Check port: `lsof -i :6379`
- Install Redis (macOS): `brew install redis`
- Install Redis (Linux): `sudo apt-get install redis-server`

#### **Issue: Out of Memory During Compilation**
```
Error: JavaScript heap out of memory
```
**Solution:**
```bash
# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
yarn build
```

### Debugging

#### Enable Debug Logging
```bash
# Backend
DEBUG=* yarn dev

# Frontend
VITE_DEBUG=true yarn dev
```

#### Check Contract State
```bash
# Verify bot exists
cast call $FACTORY_ADDRESS "bots(uint256)" 0 --rpc-url $QUICKNODE_RPC_URL

# Check bot balance
cast balance $BOT_ADDRESS --rpc-url $QUICKNODE_RPC_URL

# Read bot configuration
cast call $BOT_ADDRESS "getConfig()" --rpc-url $QUICKNODE_RPC_URL
```

#### Monitor Transactions
```bash
# Watch pending transactions
cast rpc eth_pendingTransactions --rpc-url $QUICKNODE_RPC_URL

# Check transaction status
cast tx $TX_HASH --rpc-url $QUICKNODE_RPC_URL

# Get transaction receipt
cast receipt $TX_HASH --rpc-url $QUICKNODE_RPC_URL
```

## Security Best Practices

### Development Environment

1. **Never Commit `.env` Files**
   ```bash
   # Add to .gitignore
   echo ".env
   .env.local
   .env.*.local" >> .gitignore
   ```

2. **Use Environment Variable Managers**
   ```bash
   # Load from secure vault (example with direnv)
   echo 'export QUICKNODE_RPC_URL=...' > .envrc
   direnv allow
   ```

3. **Private Key Management**
   - Never use the same key for multiple networks
   - Use hierarchical deterministic (HD) wallets
   - Rotate keys regularly
   - Consider hardware wallets for mainnet

4. **Contract Audits**
   - Before mainnet deployment, conduct security audits
   - Use professional audit firms (e.g., Trail of Bits, OpenZeppelin)
   - Run automated tools: Slither, Mythril

### Smart Contract Security

```solidity
// ✅ Good: Checks-Effects-Interactions pattern
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}

// ❌ Bad: State change after external call
function badWithdraw(uint256 amount) external {
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
    balances[msg.sender] -= amount;  // Vulnerable!
}
```

### Frontend Security

1. **Validate All Inputs**
   ```typescript
   import { z } from "zod";
   
   const BotConfigSchema = z.object({
     strategy: z.enum(["buyAndHold", "gridTrading", "arbitrage"]),
     maxGasPrice: z.number().min(1).max(500),
     initialFunding: z.bigint().min(1n),
   });
   ```

2. **Use Content Security Policy**
   ```html
   <meta http-equiv="Content-Security-Policy"
     content="default-src 'self'; script-src 'self' 'unsafe-inline'" />
   ```

3. **Sanitize User Input**
   ```typescript
   import DOMPurify from "dompurify";
   
   const clean = DOMPurify.sanitize(userInput);
   ```

### Infrastructure Security

1. **RPC Provider Security**
   - Use private RPC endpoints for production
   - Monitor for abnormal request patterns
   - Implement rate limiting

2. **API Gateway Security**
   ```typescript
   // Example: Rate limiting middleware
   import rateLimit from "express-rate-limit";
   
   const limiter = rateLimit({
     windowMs: 15 * 60 * 1000, // 15 minutes
     max: 100, // limit each IP to 100 requests per windowMs
   });
   
   app.use("/api/", limiter);
   ```

3. **Database Security**
   - Use encrypted connections (SSL/TLS)
   - Implement access controls
   - Regular backups

## Scalability & Mainnet Migration

### Preparation Checklist

- [ ] Security audit completed
- [ ] Load testing performed (1000+ concurrent users)
- [ ] Gas optimization review finished
- [ ] Mainnet RPC provider selected and tested
- [ ] Monitoring and alerting system in place
- [ ] Rollback procedures documented
- [ ] Team training completed

### Gas Optimization for Mainnet

```solidity
// Current estimate: ~250,000 gas per bot deployment
// Mainnet gas cost @ 50 gwei: 0.0125 ETH (~$50)

// Optimizations:
// 1. EIP-1167 Minimal Proxy: 10x reduction
// 2. Batch operations: 5x-10x reduction
// 3. Calldata optimization: 2x reduction
// 4. Storage packing: 3x reduction

// Total potential savings: ~100x
// New estimate: ~2,500 gas per bot (~$0.50)
```

### Mainnet Deployment Steps

```bash
# 1. Verify on mainnet network
export MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/..."
cast client-version --rpc-url $MAINNET_RPC_URL

# 2. Deploy with enhanced verification
forge script script/DeployNFTTradingBot.s.sol:DeploymentScript \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --slow  # Wait for block confirmation

# 3. Monitor deployment
cast receipt $TX_HASH --rpc-url $MAINNET_RPC_URL

# 4. Verify contract on Etherscan
# Etherscan will auto-verify with --verify flag
```

### Scaling Considerations

| Scenario | Strategy |
|----------|----------|
| 100-1000 bots | Current infrastructure sufficient |
| 10,000+ bots | Implement sharding, Layer 2 deployment |
| 100,000+ bots | Rollups (Arbitrum, Optimism), sidechains |
| 1M+ bots | Plasma chains, full data availability solutions |

### Layer 2 Migration

```bash
# Example: Arbitrum deployment
export ARBITRUM_RPC_URL="https://arb1.arbitrum.io/rpc"

# Deploy with reduced gas costs (~1/10th of mainnet)
forge script script/DeployNFTTradingBot.s.sol:DeploymentScript \
  --rpc-url $ARBITRUM_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast
```

### Performance Monitoring

```typescript
// Example: Monitor transaction throughput
async function monitorPerformance() {
  const blockTime = 12; // seconds for mainnet
  const batchSize = 100; // bots per transaction
  const tps = (batchSize / blockTime); // transactions per second
  
  console.log(`Throughput: ${tps} bots/second`);
  console.log(`Daily capacity: ${tps * 86400} bots`);
}
```

## Contributing

We welcome contributions! Here's how to get involved:

### Development Workflow

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/nft-trading-bot-system.git
   cd nft-trading-bot-system
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow [Solidity style guide](https://docs.soliditylang.org/en/latest/style-guide.html)
   - Follow [TypeScript guidelines](https://www.typescriptlang.org/docs/handbook/)
   - Add tests for new functionality
   - Update documentation

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: add new trading strategy" -m "
   - Implement grid trading strategy
   - Add unit tests for strategy validation
   - Update README with new strategy docs
   "
   ```

5. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Standards

- **Solidity**: Hardhat + OpenZeppelin standards
- **TypeScript**: ESLint + Prettier
- **Tests**: 80%+ coverage required
- **Documentation**: JSDoc comments for all public functions

### Pull Request Checklist

- [ ] Tests pass locally (`yarn test`)
- [ ] Code formatted (`yarn format`)
- [ ] No console.log statements (use logger)
- [ ] New functions have JSDoc comments
- [ ] No hardcoded values
- [ ] No security issues (run `forge test --fuzz-runs 10000`)

### Reporting Issues

Found a bug? Please report it:

1. Check [existing issues](https://github.com/yourusername/nft-trading-bot-system/issues)
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/logs if applicable
   - Environment details (OS, Node version, etc.)

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

### Third-Party Licenses

- OpenZeppelin Contracts: MIT
- Uniswap V3: BUSL-1.1 (licensing agreement required)
- Gnosis Safe: LGPL-3.0
- The Graph: BUSL-1.1

---

## Additional Resources

- [Project Overview](overview.md)
- [Architecture Flowchart](flowchart.mmd)
- [Testnet Setup Guide](docs/TESTNET_SETUP.md) *(Coming Soon)*
- [API Documentation](docs/API.md) *(Coming Soon)*
- [Contract Reference](docs/CONTRACTS.md) *(Coming Soon)*
- [Deployment Guide](docs/DEPLOYMENT.md) *(Coming Soon)*

## Support

- **Discord**: [Join our community](https://discord.gg/yourserver) *(Coming Soon)*
- **Twitter**: [@YourProject](https://twitter.com/yourproject)
- **Email**: support@yourproject.dev

## Acknowledgments

Built with ❤️ using:
- [Foundry](https://github.com/foundry-rs/foundry) - Smart contract development
- [OpenZeppelin](https://openzeppelin.com/) - Secure smart contracts
- [Uniswap](https://uniswap.org/) - Decentralized exchange
- [The Graph](https://thegraph.com/) - Blockchain indexing
- [Viem](https://viem.sh/) - Ethereum client
- [React](https://react.dev/) - User interface

---

**Last Updated**: January 2026

For the latest updates, see [CHANGELOG.md](CHANGELOG.md)
