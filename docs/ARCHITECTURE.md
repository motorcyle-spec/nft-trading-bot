## **Updated: January 2026**

# Executive Summary

---

An autonomous NFT-based trading bot factory system where each trading bot is represented as an ERC-721 token with its own secure wallet infrastructure. Bots operate independently on Uniswap V3, executing programmed strategies while ownership and control are managed through transferable NFTs with complete state preservation.

---

## System Overview

### Core Concept

This system creates a marketplace for autonomous trading bots where:

- **Each bot is an NFT** - ERC-721 token represents complete ownership
- **Bots own wallets** - Each bot controls a dedicated smart contract wallet
- **Autonomous trading** - Bots execute strategies on Uniswap V3 without manual intervention
- **Full transferability** - NFT sales include the bot, wallet, funds, and trading history
- **State preservation** - Performance metrics and configuration transfer with ownership

### Innovation Highlights

1. **Composable Ownership** - NFT → Bot → Wallet creates clear ownership chain
2. **Gas Optimized** - Minimal proxy pattern reduces deployment costs by ~10x
3. **Secure by Design** - CREATE2 with sender-based salts prevents frontrunning
4. **Market Ready** - Native OpenSea integration with rich metadata
5. **Battle Tested** - Uses proven patterns (ERC721A, Gnosis Safe, Uniswap V3)

---

## Technical Architecture

### Layer 1: User Interaction

**Purpose**: Interface for bot creation, management, and trading

**Components**:

- **Web Interface**: Built with React, Viem, Wagmi v2, RainbowKit
- **Wallet Connection**: Support for MetaMask, WalletConnect, Coinbase Wallet
- **Real-time Updates**: WebSocket connection via Quicknode Streams
- **Performance Dashboard**: Charts showing bot P&L, trades, and strategy performance

**User Flows**:

1. Connect wallet → Deploy new bot → Configure strategy → Fund wallet
2. View bot portfolio → Execute commands → Monitor performance
3. List bot on marketplace → Transfer ownership → Receive proceeds

---

### Layer 2: Factory & Deployment

**Purpose**: Secure, gas-efficient bot creation with deterministic addressing

**Factory Contract** (`BotFactory.sol`):

```solidity
Key Functions:
- deployBot(bytes32 userSalt) → Creates bot instance + NFT
- getBotAddress(address deployer, bytes32 salt) → Predict address
- updateImplementation(address newImpl) → Upgrade bot logic
- pauseFactory() → Emergency stop for critical bugs

Security Features:
- Salt = keccak256(abi.encodePacked(msg.sender, userSalt))
- Role-based access control (OpenZeppelin)
- Reentrancy guards on all state changes
- Event emission for indexing

```

**Bot Registry** (`BotRegistry.sol`):

```solidity
Mappings:
- tokenId → bot address
- bot address → tokenId
- owner → bot array
- Strategy validation and tracking

```

**Implementation Strategy**:

- **Master Contract**: Single `TradingBot.sol` implementation
- **Minimal Proxies**: Clone via EIP-1167 for each instance
- **Gas Savings**: ~10x reduction vs full contract deployment
- **Upgradeability**: Transparent proxy pattern for bug fixes

---

### Layer 3: Bot Instance

**Purpose**: Individual trading bot with strategy execution and access control

**Bot Proxy** (`BotProxy.sol` - EIP-1167):

```solidity
- Ultra-minimal bytecode (~45 bytes)
- Delegatecalls to master implementation
- Unique storage per instance
- Deterministic CREATE2 address

```

**Trading Logic** (`TradingBot.sol`):

```solidity
Core Capabilities:
- Strategy execution engine
- Risk management (stop-loss, position limits)
- Access control (only NFT holder)
- Emergency withdrawal
- Wallet management
- Performance tracking

Security:
- ReentrancyGuard on all external calls
- Rate limiting (max trades per hour)
- Slippage protection
- Oracle validation
- Pausable by NFT holder

```

**Bot State Management**:

```solidity
struct BotState {
    uint256 tokenId;
    address wallet;
    StrategyType strategy;
    uint256 totalTrades;
    int256 realizedPnL;
    uint256 createdAt;
    bool isPaused;
    RiskParams riskConfig;
}

```

---

### Layer 4: Ownership (NFT)

**Purpose**: Represent bot ownership with optimized ERC-721 implementation

**NFT Contract** (`BotNFT.sol` - ERC721A):

```solidity
Optimizations:
- Batch minting support (future multi-bot deployments)
- Reduced storage per token
- Gas-efficient transfers
- Removed balanceOf overhead (not needed)

Features:
- transferFrom() triggers bot ownership update
- Metadata URIs point to IPFS + on-chain data
- Royalty support (EIP-2981) for creator revenue
- Enumerable for portfolio viewing

```

**Metadata Structure**:

```json
{
  "name": "Trading Bot #1337",
  "description": "Autonomous DCA trading bot on Sepolia",
  "image": "ipfs://QmX.../bot-avatar.png",
  "attributes": [
    {"trait_type": "Strategy", "value": "DCA"},
    {"trait_type": "Total Trades", "value": 142},
    {"trait_type": "PnL", "value": "+$234.56"},
    {"trait_type": "Win Rate", "value": "68%"},
    {"trait_type": "Wallet Balance", "value": "1.5 ETH"},
    {"trait_type": "Created", "value": "2026-01-07"}
  ],
  "external_url": "https://yourdapp.com/bot/1337"
}

```

**Update Strategy**:

- **On-chain**: Critical stats updated on trade completion
- **IPFS**: Detailed history updated daily/weekly via pinning service
- **Dynamic NFTs**: Metadata reflects real-time bot performance

---

### Layer 5: Wallet Infrastructure

**Purpose**: Secure, isolated wallet for each bot with smart contract capabilities

**Wallet Options Analysis**:

| Feature | Smart Contract Wallet | EOA Wallet |
| --- | --- | --- |
| Gas Cost | Higher (~300k deploy) | Lower (~50k) |
| Flexibility | High (multi-sig, modules) | Low (single key) |
| Security | Best (no private key) | Good (encrypted) |
| Complexity | High | Low |
| Upgradeable | Yes | No |
| Recommendation | ✅ Production | Testing Only |

**Recommended: Gnosis Safe Pattern**:

```solidity
BotWallet.sol (Minimal Safe):
- Single owner: Bot contract
- Guard module: Risk limits enforced
- Fallback handler: Token recovery
- ERC-4337 compatible (future gasless txs)

```

**Security Features**:

- **Reentrancy Guard**: Prevent recursive calls
- **Rate Limiting**: Max trades per time window
- **Emergency Pause**: Circuit breaker for bot holder
- **Withdrawal Controls**: Time-locks on large transfers
- **Whitelist**: Approved DEXs and tokens only

---

### Layer 6: Trading Infrastructure

**Purpose**: Execute strategies on live Sepolia testnet DEXs

**Uniswap V3 Integration**:

```solidity
Key Contracts (Sepolia):
- SwapRouter: 0xE592427A0AEce92De3Edee1F18E0157C05861564
- QuoterV2: 0x61fFE014bA17989E743c5F6cB21bF9697530B21e
- Factory: 0x0227628f3F023bb0B980b67D528571c95c6DaC1c

Active Pools:
- WETH/USDC (0.05% fee): ~$42.56M volume
- Test tokens available via faucet

```

**Trading Strategies**:

1. **Dollar Cost Averaging (DCA)**:
    - Buy fixed amount at regular intervals
    - Configurable: amount, frequency, token pair
    - Risk: Low | Gas: Medium
2. **Arbitrage**:
    - Price differences between DEXs
    - Requires flash loan integration
    - Risk: Medium | Gas: High
3. **Market Making**:
    - Provide liquidity in Uni V3 range
    - Earn fees from trades
    - Risk: High (impermanent loss) | Gas: High
4. **Momentum Trading**:
    - Buy breakouts, sell resistance
    - Uses price oracles and TWAP
    - Risk: High | Gas: Medium

**Price Oracles**:

- Primary: Uniswap V3 TWAP (decentralized)
- Fallback: Chainlink price feeds (if available on Sepolia)
- Validation: Compare sources, reject outliers

---

### Layer 7: Backend Services

**Purpose**: Indexing, monitoring, and caching for optimal UX

**The Graph Indexer**:

```graphql
Indexed Events:
- BotCreated
- TradeExecuted
- OwnershipTransferred
- StrategyUpdated
- FundsDeposited/Withdrawn

Queries:
- getUserBots(owner: Address)
- getBotHistory(tokenId: ID)
- getTopPerformingBots(limit: Int)
- getMarketStats()

```

**Quicknode Streams**:

- Real-time WebSocket for trade events
- Instant UI updates on bot activity
- Monitor pending transactions
- Alert system for critical events

**Redis Cache**:

```
Cached Data:
- bot:{tokenId} → Current state (1 min TTL)
- user:{address}:bots → Bot list (5 min TTL)
- market:stats → Aggregated metrics (10 min TTL)
- price:{token} → Current prices (30 sec TTL)

```

---

### Layer 8: Secondary Market

**Purpose**: Enable bot trading with complete state transfer

**OpenSea Integration**:

- Automatic collection detection via contract standards
- Rich metadata display (performance charts)
- Royalty enforcement (5% to original creator)
- Verification badge for trusted contracts

**Custom Marketplace Features**:

- Filter by strategy type, PnL, age
- Live performance preview before purchase
- Escrow service for high-value bots
- Bot performance guarantees/warranties
- Reputation system for sellers

**Transfer Process**:

1. NFT listed on marketplace
2. Buyer purchases NFT (standard ERC-721 transfer)
3. NFT transfer triggers `_afterTokenTransfer` hook
4. Bot contract updates owner permissions automatically
5. Wallet control transfers to new owner
6. All funds and history preserved
7. New owner can immediately issue commands

---

## Security Framework

### Access Control Matrix

| Action | NFT Holder | Factory Admin | Bot Contract |
| --- | --- | --- | --- |
| Execute Trade | ✅ | ❌ | ✅ |
| Pause Bot | ✅ | ❌ | ❌ |
| Withdraw Funds | ✅ | ❌ | ❌ |
| Update Strategy | ✅ | ❌ | ❌ |
| Emergency Stop | ✅ | ✅ | ❌ |
| Upgrade Logic | ❌ | ✅ | ❌ |
| Mint NFT | ❌ | ✅ (Factory) | ❌ |

### Threat Model & Mitigations

**1. Frontrunning Attacks**:

- **Threat**: Attacker predicts CREATE2 address, deploys malicious contract first
- **Mitigation**: Include `msg.sender` in salt → unique per user

**2. Reentrancy**:

- **Threat**: Malicious contract calls back during trade execution
- **Mitigation**: OpenZeppelin ReentrancyGuard on all state changes

**3. Oracle Manipulation**:

- **Threat**: Flash loan attack manipulates price feeds
- **Mitigation**: Use Uniswap V3 TWAP (time-weighted), multi-oracle validation

**4. MEV Exploitation**:

- **Threat**: Bots sandwiched by MEV searchers
- **Mitigation**: Flashbots RPC, private mempools, slippage protection

**5. Smart Contract Bugs**:

- **Threat**: Logic errors drain funds or lock wallets
- **Mitigation**: Extensive testing, audits, bug bounty, emergency pause

**6. Private Key Compromise** (if using EOA wallets):

- **Threat**: Bot's private key leaked or stolen
- **Mitigation**: Use smart contract wallets (no private key)

**7. Sandwich Attacks**:

- **Threat**: Attacker frontruns bot trades
- **Mitigation**: MEV protection, dynamic slippage, trade batching

### Audit Checklist

- [ ]  All contracts pass Slither static analysis
- [ ]  100% test coverage with Foundry
- [ ]  Formal verification of critical functions
- [ ]  External security audit (Trail of Bits, OpenZeppelin)
- [ ]  Bug bounty program ($10k+ for critical bugs)
- [ ]  Testnet stress testing (1000+ bot deployments)
- [ ]  Gas optimization review
- [ ]  Emergency response plan documented

---

## Tech Stack

### Smart Contracts

```yaml
Language: Solidity 0.8.20+
Framework: Foundry (faster than Hardhat)
Libraries:
  - OpenZeppelin Contracts 5.0
  - ERC721A (NFT optimization)
  - Gnosis Safe Contracts
  - Uniswap V3 Periphery
Testing: Forge (unit), Anvil (local fork)
Gas Profiling: forge --gas-report
Static Analysis: Slither, Mythril

```

### Frontend

```yaml
Framework: React 18 + TypeScript
Web3 Libraries:
  - Viem (lighter than ethers.js)
  - Wagmi v2 with TanStack Query
  - RainbowKit for wallet UX
State Management: Zustand
UI Components: Tailwind CSS + Shadcn/ui
Charts: Recharts
Build Tool: Vite

```

### Backend Services

```yaml
Indexing: The Graph (subgraph)
Real-time: Quicknode Streams
Caching: Redis 7.0
IPFS: Pinata or NFT.Storage
RPC: Quicknode Sepolia endpoint
Monitoring: Sentry + Custom alerts

```

### DevOps

```yaml
Version Control: Git + GitHub
CI/CD: GitHub Actions
Contract Deploy: Foundry scripts
Frontend Deploy: Vercel
Testing: Automated on PR
Gas Reports: Posted to PR comments

```

---

## Gas Optimization Summary

### Deployment Costs (Sepolia)

| Component | Full Deploy | Minimal Proxy | Savings |
| --- | --- | --- | --- |
| Bot Contract | ~2,500,000 gas | ~250,000 gas | **90%** |
| Bot Wallet | ~300,000 gas | ~300,000 gas | 0% |
| NFT Mint | ~100,000 gas | ~50,000 gas | **50%** |
| **Total per Bot** | ~2,900,000 | ~600,000 | **79%** |

### Transaction Costs

| Action | Gas Estimate | Cost @ 50 gwei |
| --- | --- | --- |
| Deploy Bot | 600,000 | ~0.03 ETH |
| Execute Trade | 200,000 | ~0.01 ETH |
| Transfer NFT | 80,000 | ~0.004 ETH |
| Update Strategy | 50,000 | ~0.0025 ETH |
| Emergency Pause | 30,000 | ~0.0015 ETH |

---

## Risk Assessment

### Technical Risks

| Risk | Severity | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Smart contract bug | Critical | Medium | Audits, testing, bug bounty |
| Oracle manipulation | High | Low | Multi-oracle, TWAP |
| Frontrunning | Medium | High | MEV protection, slippage |
| Gas price spikes | Low | High | Gas optimization, subsidies |

### Market Risks

| Risk | Severity | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Low NFT demand | Medium | Medium | Strong marketing, utility |
| Bot underperformance | High | Medium | Strategy backtesting, transparency |
| Regulatory changes | High | Low | Legal review, compliance ready |
| Sepolia shutdown | Low | Low | Multi-network support |

---
