// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BotWallet
 * @dev Minimal Gnosis Safe implementation for secure bot fund management
 * 
 * Features:
 * - Multi-signature approval for withdrawals
 * - Execution guards and transaction limits
 * - ERC-4337 account abstraction readiness
 * - Signature verification and nonce management
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BotWallet is ReentrancyGuard {
    
    // ============ Constants ============
    
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    
    bytes32 private constant TRANSACTION_TYPEHASH =
        keccak256("SafeTransaction(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)");
    
    // ============ Enums ============
    
    enum Operation {
        CALL,
        DELEGATECALL
    }
    
    // ============ State Variables ============
    
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public immutable requiredSignatures;

    using SafeERC20 for IERC20;
    
    uint256 public nonce;
    uint256 public dailyLimit;
    uint256 public lastLimitResetTime;
    uint256 public dailySpent;
    
    mapping(bytes32 => bool) public executedTransactions;
    
    // ============ Events ============
    
    event TransactionExecuted(bytes32 indexed txHash, address target, uint256 value);
    event FundsReceived(address indexed from, uint256 amount);
    event DailyLimitUpdated(uint256 newLimit);
    
    // ============ Constructor ============
    
    constructor(
        address[] memory _owners,
        uint256 _requiredSignatures,
        uint256 _dailyLimit
    ) {
        require(_owners.length > 0, "No owners provided");
        require(_requiredSignatures <= _owners.length && _requiredSignatures > 0, "Invalid signatures required");
        require(_dailyLimit > 0, "Invalid daily limit");
        
        owners = _owners;
        requiredSignatures = _requiredSignatures;
        dailyLimit = _dailyLimit;
        lastLimitResetTime = block.timestamp;
        
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            require(!isOwner[_owners[i]], "Duplicate owner");
            isOwner[_owners[i]] = true;
        }
    }
    
    // ============ External Functions ============
    
    /**
     * @dev Execute transaction with signatures
     * @param _to Target address
     * @param _value ETH value to send
     * @param _data Call data
     * @param _signatures Concatenated signatures
     */
    function executeTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _signatures
    ) external nonReentrant {
        require(_signatures.length >= requiredSignatures * 65, "Invalid signatures length");
        require(_to != address(0), "Invalid target");
        
        _resetDailyLimit();
        require(dailySpent + _value <= dailyLimit, "Daily limit exceeded");
        
        bytes32 txHash = _getTransactionHash(_to, _value, _data);
        require(!executedTransactions[txHash], "Transaction already executed");
        
        // Verify signatures
        address lastSigner = address(0);
        for (uint256 i = 0; i < requiredSignatures; i++) {
            address signer = _recoverSigner(txHash, _signatures, i);
            require(isOwner[signer], "Invalid signature");
            require(signer > lastSigner, "Invalid signature order");
            lastSigner = signer;
        }
        
        // Execute transaction
        executedTransactions[txHash] = true;
        dailySpent += _value;
        nonce++;
        
        (bool success, ) = _to.call{value: _value}(_data);
        require(success, "Transaction failed");
        
        emit TransactionExecuted(txHash, _to, _value);
    }
    
    /**
     * @dev Set daily limit
     * @param _newLimit New limit
     */
    function setDailyLimit(uint256 _newLimit) external {
        require(msg.sender == address(this) || isOwner[msg.sender], "Not authorized");
        require(_newLimit > 0, "Invalid limit");
        
        dailyLimit = _newLimit;
        emit DailyLimitUpdated(_newLimit);
    }
    
    /**
     * @dev Deposit ETH to wallet
     */
    function depositETH() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Deposit ERC20 tokens
     * @param _token Token address
     * @param _amount Amount to deposit
     */
    function depositToken(address _token, uint256 _amount) external {
        require(_token != address(0), "Invalid token");
        require(_amount > 0, "Invalid amount");
        
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        emit FundsReceived(_token, _amount);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get owners count
     * @return Number of owners
     */
    function getOwnerCount() external view returns (uint256) {
        return owners.length;
    }
    
    /**
     * @dev Get owner by index
     * @param _index Index
     * @return Owner address
     */
    function getOwner(uint256 _index) external view returns (address) {
        require(_index < owners.length, "Index out of bounds");
        return owners[_index];
    }
    
    /**
     * @dev Get domain separator
     * @return Domain separator hash
     */
    function getDomainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(
            DOMAIN_SEPARATOR_TYPEHASH,
            keccak256(bytes("BotWallet")),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
        ));
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Get transaction hash
     * @param _to Target address
     * @param _value ETH value
     * @param _data Call data
     * @return Transaction hash
     */
    function _getTransactionHash(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            getDomainSeparator(),
            keccak256(abi.encode(
                TRANSACTION_TYPEHASH,
                _to,
                _value,
                keccak256(_data),
                uint8(Operation.CALL),
                0, // safeTxGas
                0, // baseGas
                0, // gasPrice
                address(0), // gasToken
                address(0), // refundReceiver
                nonce
            ))
        ));
    }
    
    /**
     * @dev Recover signer from signature
     * @param _hash Message hash
     * @param _signatures Concatenated signatures
     * @param _index Signature index
     * @return Signer address
     */
    function _recoverSigner(
        bytes32 _hash,
        bytes calldata _signatures,
        uint256 _index
    ) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        uint256 offset = _index * 65;
        assembly {
            r := calldataload(add(_signatures.offset, add(offset, 0x00)))
            s := calldataload(add(_signatures.offset, add(offset, 0x20)))
            v := byte(0, calldataload(add(_signatures.offset, add(offset, 0x40))))
        }
        
        return ecrecover(_hash, v, r, s);
    }
    
    /**
     * @dev Reset daily limit if needed
     */
    function _resetDailyLimit() internal {
        if (block.timestamp >= lastLimitResetTime + 1 days) {
            dailySpent = 0;
            lastLimitResetTime = block.timestamp;
        }
    }
    
    // ============ Fallback ============
    
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
}
