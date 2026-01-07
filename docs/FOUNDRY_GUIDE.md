# Foundry Configuration Guide for NFT Trading Bot System

## Overview

This guide explains the `foundry.toml` configuration for the NFT Trading Bot System smart contracts workspace. It covers compilation settings, testing configurations, deployment strategies, and optimization techniques.

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration Sections](#configuration-sections)
- [Profiles](#profiles)
- [Import Remappings](#import-remappings)
- [RPC Endpoints](#rpc-endpoints)
- [Testing & Fuzz Settings](#testing--fuzz-settings)
- [Gas Optimization](#gas-optimization)
- [Multi-Chain Support](#multi-chain-support)
- [Build Performance](#build-performance)
- [Common Issues](#common-issues)
- [Deployment Workflow](#deployment-workflow)

## Quick Start

### Development Workflow

```bash
# Fast iteration (no optimization)
forge test --profile test

# Production-ready build
forge build --profile mainnet

# Generate gas report
forge test --gas-report --profile gas-report

# Fork Sepolia locally
anvil --fork-url $QUICKNODE_RPC_URL

# Run with code coverage
forge coverage
```

### Core Configuration Highlights

```toml
# Solidity compiler version
solc-version = "0.8.20"

# Enable optimization with LLVM IR (10-20% gas savings)
[profile.default.optimizer]
enabled = true
runs = 200
via_ir = true

# EVM version for compatibility
evm_version = "paris"

# Fuzz test runs (higher = more coverage)
[profile.default.fuzz]
runs = 256
```

## Configuration Sections

### Solidity Version

```toml
solc-version = "0.8.20"
```

**Why 0.8.20+:**
- Improved memory safety
- Better optimizer heuristics
- via-IR compatibility
- Latest security patches

**Checking your contracts:**
```solidity
pragma solidity 0.8.20;  // Must match foundry.toml
```

### Optimizer Settings

```toml
[profile.default.optimizer]
enabled = true
runs = 200
via_ir = true
```

**What each setting does:**

| Setting | Effect | Tradeoff |
|---------|--------|----------|
| `enabled = true` | Optimize bytecode | ~10% slower compilation |
| `runs = 200` | Gas optimization depth | 200 = good balance |
| `via_ir = true` | Use LLVM backend | 30-50% slower, 10-20% less gas |

**Choosing `runs` value:**

| Value | Use Case | Gas Savings | Compile Time |
|-------|----------|------------|--------------|
| 0-100 | Quick iteration | Minimal | Very fast |
| 200 | Production (DEFAULT) | Good (10-15%) | Moderate |
| 1000+ | Critical contracts | Best (15-20%) | Slow |

### EVM Version

```toml
evm_version = "paris"
```

**Options:**
- `paris` (default) - Current mainnet, broad compatibility
- `shanghai` - Adds push0 opcode (saves 1 gas per instance)
- `cancun` - Adds mcopy opcode (minimal benefit currently)
- `istanbul` - For older chain compatibility

**Choosing EVM version:**
```
Development: paris (safest)
Testnet: paris (broad compatibility)
Mainnet: paris (proven, stable)
Layer 2: Check network specs
```

### Project Structure

```toml
src = "src"           # Source contracts
test = "test"         # Test files
out = "out"           # Compiled output
libs = ["lib"]        # Dependencies
cache_path = "cache"  # Incremental compilation
```

**Directory layout:**
```
contracts/
├── src/
│   ├── BotFactory.sol
│   ├── TradingBot.sol
│   ├── interfaces/
│   │   └── IBotFactory.sol
│   └── libraries/
│       └── BotLibrary.sol
├── test/
│   ├── BotFactory.t.sol
│   └── TradingBot.t.sol
├── lib/
│   ├── openzeppelin-contracts/
│   ├── uniswap-v3-core/
│   └── gnosis-safe-contracts/
└── foundry.toml
```

## Profiles

Foundry supports multiple profiles for different scenarios.

### Profile: default

Used for normal development and testing.

```toml
[profile.default]
solc-version = "0.8.20"

[profile.default.optimizer]
enabled = true
runs = 200
via_ir = true

[profile.default.fuzz]
runs = 256
```

**Usage:**
```bash
forge test                    # Uses default profile
forge build                   # Uses default profile
```

### Profile: test

Fast compilation for rapid iteration (no optimization).

```toml
[profile.test]
solc-version = "0.8.20"

[profile.test.optimizer]
enabled = false
via_ir = false

[profile.test.fuzz]
runs = 1000  # More thorough than default
```

**Usage:**
```bash
forge test --profile test
forge build --profile test
```

**When to use:**
- During development for fast feedback
- Quick syntax checking
- Before final testing

### Profile: gas-report

Optimized settings for accurate gas measurements.

```toml
[profile.gas-report]
solc-version = "0.8.20"

[profile.gas-report.optimizer]
enabled = true
runs = 200
via_ir = true

[profile.gas-report.fuzz]
runs = 256
```

**Usage:**
```bash
forge test --gas-report --profile gas-report
```

**Output example:**
```
BotFactory::deployBot                       250,234  250,234
BotFactory::getBotAddress                   45,232   45,232
TradingBot::swap                            125,456  125,456
TradingBot::addLiquidity                    175,234  175,234
```

### Profile: sepolia

Testnet-specific optimizations.

```toml
[profile.sepolia]
solc-version = "0.8.20"

[profile.sepolia.optimizer]
enabled = true
runs = 200
via_ir = true

[profile.sepolia.fuzz]
runs = 256
```

**Usage:**
```bash
forge build --profile sepolia
forge script script/Deploy.s.sol --fork-url sepolia
```

### Profile: mainnet

Production-grade optimization.

```toml
[profile.mainnet]
solc-version = "0.8.20"

[profile.mainnet.optimizer]
enabled = true
runs = 200
via_ir = true

[profile.mainnet.fuzz]
runs = 100  # Fewer runs for faster CI
```

**Usage:**
```bash
forge build --profile mainnet
forge script script/Deploy.s.sol --broadcast --rpc-url mainnet
```

## Import Remappings

Remappings simplify import statements.

### Current Remappings

```toml
remappings = [
  "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
  "@uniswap/v3-core/=lib/uniswap-v3-core/contracts/",
  "@contracts/=src/",
  "@interfaces/=src/interfaces/",
  "@libraries/=src/libraries/",
]
```

### Using Remappings

**Without remapping:**
```solidity
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
```

**With remapping:**
```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

### Adding New Remappings

```toml
# For new library
remappings = [
  "new-lib/=lib/new-lib/src/",
]
```

### Viewing All Remappings

```bash
forge remappings
# Output all current remappings
```

## RPC Endpoints

### Configuration

```toml
[rpc_endpoints]
sepolia = "${QUICKNODE_RPC_URL}"
sepolia_alchemy = "${ALCHEMY_RPC_URL}"
mainnet = "https://eth.infura.io/v3/${INFURA_KEY}"
mumbai = "https://rpc-mumbai.maticvigil.com"
polygon = "https://polygon-rpc.com"
```

### Usage in Scripts

```bash
# Deploy to Sepolia
forge script script/Deploy.s.sol --fork-url sepolia

# Verify on mainnet
cast call $ADDRESS "name()" --rpc-url mainnet

# Read state from Polygon Amoy testnet
cast balance $ADDRESS --rpc-url amoy
```

### Environment Variables

RPC endpoints use `${VAR_NAME}` syntax to reference environment variables:

```bash
# Set in shell
export QUICKNODE_RPC_URL="https://sepolia.quicknode.pro/..."
export ALCHEMY_RPC_URL="https://eth-sepolia.g.alchemy.com/..."

# Or load from .env
source .env
```

## Testing & Fuzz Settings

### Fuzz Testing Configuration

```toml
[profile.default.fuzz]
runs = 256
max_test_rejects = 65536
seed = 0
```

**What each setting does:**

| Setting | Purpose |
|---------|---------|
| `runs` | Number of random inputs per test |
| `max_test_rejects` | Max failed inputs before stopping |
| `seed` | Random seed (0 = random each time) |

### Fuzz Test Example

```solidity
// test/BotFactory.t.sol
function testFuzzBotDeployment(bytes32 userSalt) public {
    // This function runs 256 times with random userSalt values
    vm.assume(userSalt != bytes32(0)); // Filter out edge cases
    
    address bot = factory.deployBot(userSalt);
    assertNotEq(bot, address(0));
}
```

### Fuzz Testing Strategy

**Light testing (CI/CD):**
```toml
[profile.default.fuzz]
runs = 256  # Fast, catches most bugs
```

**Heavy testing (before audit):**
```toml
[profile.default.fuzz]
runs = 10000  # Thorough, slow
```

**Command-line override:**
```bash
forge test --fuzz-runs 10000
```

## Gas Optimization

### Measuring Gas Usage

```bash
# Generate gas report
forge test --gas-report

# By specific test file
forge test --gas-report --match-path "test/BotFactory.t.sol"

# Compare profiles
forge test --gas-report --profile test
forge test --gas-report --profile mainnet
```

### Gas Report Interpretation

```
BotFactory::deployBot:
  avg: 250234 (average gas)
  min: 249000 (minimum gas)
  max: 252000 (maximum gas)

TradingBot::swap:
  avg: 125456
  min: 125000
  max: 125900
```

### Optimization Techniques

**1. Use via-IR for LLVM optimization:**
```toml
[profile.default.optimizer]
via_ir = true  # 10-20% gas savings
```

**Storage packing:**
```solidity
// Bad: 3 storage slots
uint256 a;
uint8 b;
uint256 c;

// Good: 2 storage slots (saves ~20,000 gas per deployment)
uint256 a;
uint256 c;
uint8 b;
```

**Batch operations:**
```solidity
// Deploy multiple bots in one transaction
// Saves: 21,000 gas per transaction overhead
```

**Loop optimization:**
```solidity
// Use `unchecked` for array indices
for (uint256 i = 0; i < length; ) {
    // ... code ...
    unchecked { ++i; }  // Saves ~20 gas per iteration
}
```

### Expected Gas Costs

| Operation | Gas Cost | Notes |
|-----------|----------|-------|
| Bot deployment | 250,000 | With proxy |
| Bot transfer (NFT) | 50,000 | ERC-721 transfer |
| Swap execution | 125,000 | Uniswap V3 |
| Add liquidity | 175,000 | Complex routing |
| State update | 5,000-20,000 | Depends on storage |

## Multi-Chain Support

### Current Network Targets

**Primary:**
- Ethereum Sepolia (testnet)
- Ethereum Mainnet (production)

**Secondary (Scaling Solutions):**
- Polygon (low gas, use Amoy testnet as of Jan 2026)
- Arbitrum (fast finality, use Arbitrum Sepolia testnet)
- Optimism (EVM-equivalent, use OP Sepolia testnet)

### Multi-Chain Configuration

```toml
[rpc_endpoints]
# Ethereum
sepolia = "${QUICKNODE_RPC_URL}"
mainnet = "${MAINNET_RPC_URL}"

# Polygon (Mumbai deprecated April 2024, use Amoy)
amoy = "https://rpc-amoy.maticvigil.com"
polygon = "https://polygon-rpc.com"

# Arbitrum
arbitrum_sepolia = "https://sepolia-rollup.arbitrum.io/rpc"
arbitrum = "https://arb1.arbitrum.io/rpc"

# Optimism
op_sepolia = "https://sepolia.optimism.io"
op_mainnet = "https://mainnet.optimism.io"
```

### Block Time Considerations

| Chain | Block Time | Implications |
|-------|-----------|--------------|
| Ethereum | 12 seconds | Standard test setup |
| Polygon | 2-3 seconds | Faster finality |
| Arbitrum | 250ms | Very fast |
| Optimism | 2 seconds | Fast |

### Testing on Multiple Chains

```bash
# Test on Sepolia
forge test --fork-url sepolia

# Test on Polygon Amoy (Mumbai deprecated April 2024)
forge test --fork-url amoy

# Test on Arbitrum Sepolia
forge test --fork-url arbitrum_sepolia

# Compare gas across chains
forge test --gas-report --fork-url sepolia
forge test --gas-report --fork-url amoy
forge test --gas-report --fork-url arbitrum_sepolia
```

### Chain-Specific Considerations

**Gas prices vary:**
```javascript
// Adjust limits per chain
if (chainId === 1) {
    maxGasPrice = 200 gwei;  // Ethereum
} else if (chainId === 137) {
    maxGasPrice = 100 gwei;  // Polygon
} else if (chainId === 42161) {
    maxGasPrice = 5 gwei;    // Arbitrum
}
```

## Build Performance

### Compilation Time Breakdown

| Scenario | Time | Notes |
|----------|------|-------|
| Clean build (no via-IR) | 5-10s | Fast |
| Clean build (via-IR) | 15-30s | Better optimization |
| Incremental build | 1-3s | From cache |
| Full test suite | 30-60s | Including tests |

### Speeding Up Builds

**1. Skip library recompilation:**
```bash
forge build --skip-library
```

**2. Use caching:**
```bash
# Cache is automatic, but ensure cache_path exists
cache_path = "cache"
```

**3. Fast testing profile:**
```bash
forge test --profile test  # No optimization
```

**4. Parallel testing (if available):**
```bash
forge test --jobs 4
```

### Cache Management

```bash
# Clear all cache
rm -rf cache out

# Clear specific contract cache
rm cache/*/BotFactory.json

# Rebuild
forge build
```

## Common Issues

### "Compiler version mismatch"

**Problem:**
```
Error: Compiler version 0.8.19 in pragma does not match 0.8.20
```

**Solution:**
```solidity
// File: src/BotFactory.sol
pragma solidity 0.8.20;  // Must match foundry.toml
```

### "Import path not found"

**Problem:**
```
Error: Could not find @openzeppelin/contracts
```

**Solution:**
```bash
# Check remappings
forge remappings

# Verify library exists
ls lib/openzeppelin-contracts/

# Update remapping
# remappings = [
#   "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
# ]
```

### "Contract too large for deployment"

**Problem:**
```
Error: Bytecode size exceeds 24KB limit (EIP-170)
```

**Solutions:**
1. Use proxy pattern:
```solidity
// Reduce contract size by splitting logic
contract BotFactoryV1 is Initializable {
    // Core logic only
}
```

2. Remove unused code:
```bash
forge build --profile test  # Check unused code
```

3. Enable via-IR optimization:
```toml
via_ir = true  # Better compression
```

### "Tests pass locally but fail in CI"

**Causes:**
- Different Solidity version
- Non-deterministic random seed
- Forking different block

**Solutions:**
```toml
# Set fixed seed for reproducibility
[profile.default.fuzz]
seed = 12345  # Instead of 0 (random)

# Use specific block number
[anvil]
fork_block_number = 5000000
```

### "Out of gas during compilation"

**Problem:**
```
Error: Out of memory during compilation
```

**Solutions:**
```bash
# Disable via-IR temporarily
forge build --profile test

# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
forge build
```

## Deployment Workflow

### Testnet (Sepolia) Deployment

**Step 1: Compile with testnet profile**
```bash
forge build --profile sepolia
```

**Step 2: Deploy via script**
```bash
forge script script/DeployNFTTradingBot.s.sol \
  --fork-url sepolia \
  --broadcast \
  --verify
```

**Step 3: Verify contract**
```bash
forge verify-contract \
  0xYourContractAddress \
  src/BotFactory.sol:BotFactory \
  --etherscan-api-key $ETHERSCAN_KEY
```

### Mainnet Deployment

**Step 1: Dry-run first (critical!)**
```bash
forge script script/DeployNFTTradingBot.s.sol \
  --fork-url mainnet
  # No --broadcast flag = simulation only
```

**Step 2: Review output**
```
...
Simulated execution:
  - Deploy BotFactory: 0x...
  - Initialize: ✓
  - Total gas: 500,000 gas
  - Cost at 50 gwei: 0.025 ETH (~$100)
```

**Step 3: Broadcast to mainnet**
```bash
forge script script/DeployNFTTradingBot.s.sol \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY
```

**⚠️ CRITICAL: Keep private key secure**
```bash
# Use environment variable (never hardcode)
export DEPLOYER_PRIVATE_KEY="0x..."

# Or use keystore
forge script ... --keystore ~/.foundry/keystore
```

## Best Practices Summary

1. **Use version control for foundry.toml**
   - Commit changes to git
   - Consistent builds across team

2. **Test with multiple profiles**
   ```bash
   forge test --profile test        # Fast iteration
   forge test --profile default     # Normal testing
   forge test --gas-report --profile gas-report  # Gas optimization
   ```

3. **Always dry-run before broadcast**
   - Check gas costs
   - Verify state changes
   - Avoid accidental deployments

4. **Use specific fork block numbers**
   - Reproducible tests
   - No network dependency for deterministic testing

5. **Keep fuzz runs reasonable**
   - Development: 256 runs (fast)
   - Pre-audit: 10,000 runs (thorough)

6. **Monitor gas reports**
   - Compare across profiles
   - Track optimizations over time
   - Set gas budgets per function

---

**Last Updated:** January 7, 2026
