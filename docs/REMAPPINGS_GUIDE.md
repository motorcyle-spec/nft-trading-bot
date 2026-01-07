# Foundry Remappings Guide - NFT Trading Bot System

## Overview

Remappings in Foundry map virtual import paths to actual library directories on disk. They simplify imports, improve code portability, and reduce coupling to specific directory structures.

## Quick Reference

### Current Remappings

```
@openzeppelin/contracts/        → lib/openzeppelin-contracts/contracts/
@openzeppelin/contracts-upgradeable/ → lib/openzeppelin-contracts-upgradeable/contracts/
erc721a/                        → lib/erc721a/contracts/
@gnosis.pm/safe-contracts/      → lib/gnosis-safe/contracts/
@uniswap/v3-core/               → lib/uniswap-v3-core/contracts/
@uniswap/v3-periphery/          → lib/uniswap-v3-periphery/contracts/
@uniswap/sdk-core/              → lib/uniswap-sdk-core/src/
solmate/                        → lib/solmate/src/
@contracts/                     → src/
@interfaces/                    → src/interfaces/
@libraries/                     → src/libraries/
```

## Purpose of Remappings

### 1. **Simplified Imports**

**Without remappings:**
```solidity
import "../../../../../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../../../../../../lib/erc721a/contracts/ERC721A.sol";
import "../interfaces/IBotFactory.sol";
```

**With remappings:**
```solidity
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/ERC721A.sol";
import "@interfaces/IBotFactory.sol";
```

**Benefits:**
- ✅ Cleaner, more readable code
- ✅ Easier to understand dependencies at a glance
- ✅ Less prone to off-by-one errors in `../` paths
- ✅ Self-documenting imports

### 2. **Reduced Coupling to Directory Structure**

**Without remappings:**
If you move a contract from `src/` to `src/core/`, all relative imports break:
```solidity
// Before move (in src/BotFactory.sol)
import "../../interfaces/IBotFactory.sol";  // Works

// After move (in src/core/BotFactory.sol)
import "../../interfaces/IBotFactory.sol";  // BROKEN! Need to change
import "../../../interfaces/IBotFactory.sol";  // Ugly
```

**With remappings:**
```solidity
// Before move (in src/BotFactory.sol)
import "@interfaces/IBotFactory.sol";  // Works

// After move (in src/core/BotFactory.sol)
import "@interfaces/IBotFactory.sol";  // Still works! No changes needed
```

### 3. **Clear Dependency Management**

Remappings make it obvious where code comes from:

```solidity
// External library (openzeppelin)
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// External library (uniswap)
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

// Project code
import "@contracts/BotFactory.sol";
import "@interfaces/IBotFactory.sol";

// Inline library
import "solmate/tokens/ERC721.sol";
```

## Remappings File Location

**Primary location:** `foundry.toml`
```toml
[profile.default]
remappings = [
  "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
  # ...
]
```

**Secondary location:** `remappings.txt` (auto-generated reference)
```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
# ...
```

**Precedence:** `foundry.toml` > `remappings.txt`

## Key Remappings Explained

### OpenZeppelin Contracts

**Mapping:**
```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

**Contains:**
- `access/` - AccessControl, Ownable (role-based access)
- `token/` - ERC20, ERC721, ERC1155
- `security/` - ReentrancyGuard, Pausable
- `utils/` - Address, Counters, Multicall
- `proxy/` - Transparent proxies, UUPS proxies

**Usage in bot contracts:**
```solidity
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
```

### ERC721A - Optimized NFT Standard

**Mapping:**
```
erc721a/=lib/erc721a/contracts/
```

**Purpose:** Gas-optimized ERC721 implementation

**Comparison:**
| Operation | Standard ERC721 | ERC721A |
|-----------|-----------------|---------|
| Mint first | 55,000 gas | 25,000 gas |
| Mint subsequent | 55,000 gas | 100-150 gas |
| Batch mint 100 | 5.5M gas | ~27,000 gas |

**Usage in bot NFT:**
```solidity
import "erc721a/ERC721A.sol";

contract BotNFT is ERC721A {
    // ... bot implementation
}
```

### Gnosis Safe Contracts

**Mapping:**
```
@gnosis.pm/safe-contracts/=lib/gnosis-safe/contracts/
```

**Contains:**
- `GnosisSafe.sol` - Multi-sig wallet contract
- `GnosisSafeProxy.sol` - Safe proxy for deterministic addresses
- `SafeFactory.sol` - Factory for creating safes
- `base/` - BaseGuard, Executor, etc.

**Usage in bot wallet management:**
```solidity
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
```

### Uniswap V3 Periphery

**Mapping:**
```
@uniswap/v3-periphery/=lib/uniswap-v3-periphery/contracts/
```

**Critical interfaces:**
- `ISwapRouter` - Execute swaps
- `INonfungiblePositionManager` - Manage LP positions
- `IQuoterV2` - Price quotes

**Usage in trading bot:**
```solidity
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
```

### Uniswap V3 Core

**Mapping:**
```
@uniswap/v3-core/=lib/uniswap-v3-core/contracts/
```

**Contains:**
- `IUniswapV3Pool` - Pool interface
- `IUniswapV3Factory` - Factory interface
- `UniswapV3Pool.sol` - Core pool implementation

**Usage in bot strategy:**
```solidity
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
```

### Project-Level Mappings

**Mappings:**
```
@contracts/=src/
@interfaces/=src/interfaces/
@libraries/=src/libraries/
```

**Benefits:**
- Consistent import style across project
- Easy refactoring (move files, imports stay same)
- Clear separation by type

**Usage:**
```solidity
// In any contract
import "@contracts/BotFactory.sol";
import "@interfaces/IBotFactory.sol";
import "@libraries/BotLibrary.sol";

// Instead of relative paths like:
import "../BotFactory.sol";
import "../interfaces/IBotFactory.sol";
import "../libraries/BotLibrary.sol";
```

## Portability Implications

### Issue 1: Machine-Specific Paths

**Problem:**
```
# On Developer A's machine:
lib/openzeppelin-contracts/

# On Developer B's machine:
/home/devb/projects/bot-system/lib/openzeppelin-contracts/

# On CI/CD:
/github/workspace/lib/openzeppelin-contracts/
```

**Solution:** Remappings are relative to `foundry.toml` directory
```
# foundry.toml is in contracts/
# So remappings are relative to contracts/ directory

@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
# Actually resolves to: contracts/lib/openzeppelin-contracts/contracts/
```

**Result:** ✅ Works on all machines with same directory structure

### Issue 2: Different Directory Structures

**Problem:** Team members with different `lib/` layouts:
```
# Dev A:
lib/
├── openzeppelin-contracts/
├── erc721a/

# Dev B:
vendor/
├── openzeppelin-contracts/
├── erc721a/
```

**Solution:**
```bash
# Dev A uses: foundry.toml in contracts/
# Dev B uses: foundry.toml in contracts/ with vendor/ remappings

# In Dev B's foundry.toml:
remappings = [
  "@openzeppelin/contracts/=vendor/openzeppelin-contracts/contracts/",
  # ...
]
```

### Issue 3: CI/CD Consistency

**Problem:** CI/CD cloning fails because of missing dependencies

**Solution:** Use Foundry's submodule support
```bash
# Install dependencies
forge install

# All dependencies go to lib/
# Remappings work automatically

# Verify in CI:
forge remappings
forge build
```

## Version-Specific Mappings

### Scenario: Multiple Versions of Same Library

**Problem:** Need OpenZeppelin v4 and v5 simultaneously
```solidity
// Some contracts use v4
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// New contracts use v5
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

**Solution:** Custom remappings with version suffix
```
@openzeppelin/contracts/=lib/openzeppelin-contracts-v5/contracts/
@openzeppelin-v4/contracts/=lib/openzeppelin-contracts-v4/contracts/
```

**Usage:**
```solidity
// Old code
import "@openzeppelin-v4/contracts/token/ERC721/ERC721.sol";

// New code
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

**⚠️ Note:** This approach is complex and should be avoided if possible. Instead:
- Plan upgrades carefully
- Upgrade all contracts at once
- Test thoroughly before migration

## Conflicts and Edge Cases

### Case 1: Conflicting Remappings

**Problem:**
```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts-alt/contracts/
```

**Result:** First definition wins (foundry.toml takes precedence)

**Solution:** Remove duplicates, verify with:
```bash
forge remappings
```

### Case 2: Nested Library Remappings

**Problem:** Library has its own imports that conflict
```
lib/
├── openzeppelin-contracts/
│   └── contracts/
│       └── token/
│           └── ERC721/
│               ├── ERC721.sol
│               └── IERC721.sol  <- depends on @openzeppelin/contracts/
```

**Solution:** Foundry handles this automatically - nested remappings work

### Case 3: Circular Dependencies

**Problem:**
```
@contracts/BotFactory.sol imports @interfaces/IBotFactory.sol
@interfaces/IBotFactory.sol imports @contracts/BotFactory.sol  ← Circular!
```

**Solution:** Use proper interface segregation
```solidity
// @interfaces/IBotFactory.sol - Pure interface only
interface IBotFactory {
    // ...
}

// @contracts/BotFactory.sol - Implementation
import "@interfaces/IBotFactory.sol";
contract BotFactory is IBotFactory {
    // ...
}
```

### Case 4: Library Subdirectory Imports

**Problem:** Importing from nested directories
```solidity
// This path is deep
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
```

**Solution:** Either accept the full path, or add shorter remapping:
```
# Option 1: Keep full path (clearest, shows full import hierarchy)
@uniswap/v3-periphery/=lib/uniswap-v3-periphery/contracts/

# Option 2: Map directly to interfaces (shorter but less clear)
@uniswap/interfaces/=lib/uniswap-v3-periphery/contracts/interfaces/
```

## Managing Remappings

### Auto-Generate Remappings

Foundry can generate remappings from installed dependencies:

```bash
# Generate remappings
forge remappings

# Save to remappings.txt
forge remappings > remappings.txt

# Output:
@gnosis.pm/safe-contracts/=lib/gnosis-safe/contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/
@uniswap/sdk-core/=lib/uniswap-sdk-core/src/
@uniswap/v3-core/=lib/uniswap-v3-core/contracts/
@uniswap/v3-periphery/=lib/uniswap-v3-periphery/contracts/
erc721a/=lib/erc721a/contracts/
solmate/=lib/solmate/src/
```

### View All Remappings

```bash
forge remappings --all
# Shows all active remappings (including transitive)
```

### Test Remappings

```bash
# Build to verify all imports resolve
forge build

# Compile specific contract
forge build --path src/BotFactory.sol
```

### Update Remappings After Installing Dependencies

```bash
# Install new library
forge install openzeppelin/openzeppelin-contracts

# Update remappings
forge remappings > remappings.txt
```

## Best Practices

### 1. Use Consistent Naming

```solidity
// ✅ GOOD - Consistent naming conventions
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@interfaces/IBotFactory.sol";

// ❌ INCONSISTENT - Mixed naming styles
import "@openzeppelin/contracts/access/Ownable.sol";
import "uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../interfaces/IBotFactory.sol";
```

### 2. Document Custom Mappings

```solidity
/**
 * Custom Remappings Guide:
 * 
 * External Libraries:
 *   @openzeppelin/contracts/ - Access control, tokens, security
 *   @uniswap/v3-periphery/ - Swapping and liquidity
 *   erc721a/ - Optimized NFT implementation
 *   @gnosis.pm/safe-contracts/ - Multi-sig wallets
 * 
 * Project Code:
 *   @contracts/ - Main contract implementations
 *   @interfaces/ - Interface definitions
 *   @libraries/ - Utility libraries
 */
```

### 3. Keep Remappings in Version Control

```bash
# Add foundry.toml to git
git add contracts/foundry.toml

# OR add remappings.txt for reference
git add contracts/remappings.txt
```

### 4. Use IDE Support

Most Solidity IDEs (VSCode with Solidity extension) support remappings from `foundry.toml`:

```bash
# Install VSCode extension
# ms-python.python
# JuanBlanco.solidity
```

### 5. Organize Project Mappings by Function

```
@contracts/core/     - Core bot logic
@contracts/trading/  - Trading strategies
@contracts/access/   - Access control
@interfaces/core/    - Core interfaces
@interfaces/trading/ - Trading interfaces
@libraries/math/     - Math utilities
@libraries/storage/  - Storage helpers
```

## Troubleshooting

### "Import not found" Error

```
Error: (4:1): File not found. Searched:
  - @openzeppelin/contracts/access/Ownable.sol
```

**Solutions:**
1. Check remappings with `forge remappings`
2. Verify library is installed: `ls lib/openzeppelin-contracts/`
3. Rebuild: `forge build --force`

### Different Behavior on Different Machines

**Check:**
```bash
# On each machine
forge remappings | grep openzeppelin
# Should output same remapping
```

**Common causes:**
- Different directory structures
- Outdated git submodules
- Platform-specific path issues (Windows vs Unix)

### Slow Imports/Compilation

**Solutions:**
1. Reduce number of remappings (only map what's used)
2. Use `--skip-library` flag: `forge build --skip-library`
3. Clear cache: `rm -rf cache out`

---

## Quick Reference Commands

```bash
# View all remappings
forge remappings

# Generate remappings file
forge remappings > remappings.txt

# Build with custom remappings
forge build --remappings "@contracts/=src/"

# View specific remapping
forge remappings | grep openzeppelin

# Check if import resolves
forge build --path src/BotFactory.sol

# Debug import paths
forge tree
```

## Additional Resources

- [Foundry Book - Remappings](https://book.getfoundry.sh/reference/config/remappings)
- [Solidity Documentation - Imports](https://docs.soliditylang.org/en/latest/layout-of-source-files.html#importing-other-source-files)
- [OpenZeppelin Contracts Documentation](https://docs.openzeppelin.com/contracts/)
- [Uniswap V3 Documentation](https://docs.uniswap.org/contracts/v3/overview)

---

**Last Updated:** January 7, 2026
