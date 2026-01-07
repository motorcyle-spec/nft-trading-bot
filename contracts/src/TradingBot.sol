// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TradingBot
 * @dev Core trading bot contract with strategy execution
 * 
 * Implements:
 * - BotState struct for bot configuration
 * - DCA (Dollar Cost Averaging) strategy
 * - Arbitrage strategy
 * - Custom strategy support
 * - Risk parameter validation
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TradingBot is Ownable, ReentrancyGuard {
    
    using SafeERC20 for IERC20;
    
    // ============ Enums ============
    
    enum StrategyType {
        DCA,
        ARBITRAGE,
        CUSTOM
    }
    
    enum BotStatus {
        ACTIVE,
        PAUSED,
        STOPPED
    }
    
    // ============ Structs ============
    
    struct BotState {
        string name;
        StrategyType strategy;
        BotStatus status;
        address baseToken;
        address quoteToken;
        uint256 tradeAmount;
        uint256 minProfitTarget;
        uint256 maxDrawdown;
        uint256 lastTradeTime;
        uint256 totalTrades;
        int256 totalPnL;
        uint256 createdAt;
    }
    
    struct Trade {
        uint256 timestamp;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        int256 pnl;
    }
    
    // ============ State Variables ============
    
    BotState public botState;
    Trade[] public tradeHistory;
    
    address public immutable factory;
    
    mapping(address => uint256) public tokenBalance;
    
    // ============ Events ============
    
    event BotInitialized(string indexed name, StrategyType strategy);
    event TradeExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        int256 pnl
    );
    event StrategyUpdated(StrategyType newStrategy);
    event BotStatusChanged(BotStatus newStatus);
    event FundsDeposited(address indexed token, uint256 amount);
    event FundsWithdrawn(address indexed token, uint256 amount);
    
    // ============ Modifiers ============
    
    modifier onlyActive() {
        require(botState.status == BotStatus.ACTIVE, "Bot not active");
        _;
    }
    
    modifier onlyOwnerOrFactory() {
        require(msg.sender == owner() || msg.sender == factory, "Not authorized");
        _;
    }
    
    // ============ Constructor ============
    
    constructor() Ownable(msg.sender) {
        factory = msg.sender;
    }
    
    // ============ Initialization ============
    
    /**
     * @dev Initialize bot with strategy configuration
     * @param _name Bot name
     * @param _strategy Trading strategy type
     * @param _baseToken Primary trading token
     * @param _quoteToken Quote token for trading pairs
     * @param _tradeAmount Amount per trade
     * @param _minProfit Minimum profit target percentage
     * @param _maxDrawdown Maximum allowed drawdown percentage
     */
    function initialize(
        string calldata _name,
        StrategyType _strategy,
        address _baseToken,
        address _quoteToken,
        uint256 _tradeAmount,
        uint256 _minProfit,
        uint256 _maxDrawdown
    ) external {
        require(msg.sender == factory, "Only factory can initialize");
        require(_baseToken != address(0), "Invalid base token");
        require(_quoteToken != address(0), "Invalid quote token");
        require(_tradeAmount > 0, "Invalid trade amount");
        require(_minProfit <= 10000, "Invalid profit target"); // Max 100%
        require(_maxDrawdown <= 10000, "Invalid max drawdown"); // Max 100%
        
        botState = BotState({
            name: _name,
            strategy: _strategy,
            status: BotStatus.ACTIVE,
            baseToken: _baseToken,
            quoteToken: _quoteToken,
            tradeAmount: _tradeAmount,
            minProfitTarget: _minProfit,
            maxDrawdown: _maxDrawdown,
            lastTradeTime: 0,
            totalTrades: 0,
            totalPnL: 0,
            createdAt: block.timestamp
        });
        
        emit BotInitialized(_name, _strategy);
    }
    
    // ============ External Functions ============
    
    /**
     * @dev Deposit funds to bot
     * @param _token Token address
     * @param _amount Amount to deposit
     */
    function depositFunds(address _token, uint256 _amount) external onlyOwner nonReentrant {
        require(_token != address(0), "Invalid token");
        require(_amount > 0, "Invalid amount");
        
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        tokenBalance[_token] += _amount;
        
        emit FundsDeposited(_token, _amount);
    }
    
    /**
     * @dev Withdraw funds from bot
     * @param _token Token address
     * @param _amount Amount to withdraw
     */
    function withdrawFunds(address _token, uint256 _amount) external onlyOwner nonReentrant {
        require(_amount > 0 && _amount <= tokenBalance[_token], "Invalid amount");
        
        tokenBalance[_token] -= _amount;
        IERC20(_token).safeTransfer(msg.sender, _amount);
        
        emit FundsWithdrawn(_token, _amount);
    }
    
    /**
     * @dev Execute a trade (simplified for demonstration)
     * @param _tokenIn Input token
     * @param _tokenOut Output token
     * @param _amountIn Amount to trade
     * @param _minAmountOut Minimum output amount
     */
    function executeTrade(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _minAmountOut
    ) external onlyOwner onlyActive nonReentrant {
        require(tokenBalance[_tokenIn] >= _amountIn, "Insufficient balance");
        require(_amountIn > 0, "Invalid amount");
        
        // In production, this would interact with Uniswap V3 or similar
        uint256 amountOut = _estimateSwapAmount(_amountIn);
        require(amountOut >= _minAmountOut, "Slippage too high");
        
        // Record trade
        tokenBalance[_tokenIn] -= _amountIn;
        tokenBalance[_tokenOut] += amountOut;
        
        int256 pnl = _calculatePnL(_amountIn, amountOut);
        
        Trade memory trade = Trade({
            timestamp: block.timestamp,
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            amountIn: _amountIn,
            amountOut: amountOut,
            pnl: pnl
        });
        
        tradeHistory.push(trade);
        botState.lastTradeTime = block.timestamp;
        botState.totalTrades++;
        botState.totalPnL += pnl;
        
        emit TradeExecuted(_tokenIn, _tokenOut, _amountIn, amountOut, pnl);
    }
    
    /**
     * @dev Update strategy type
     * @param _newStrategy New strategy type
     */
    function updateStrategy(StrategyType _newStrategy) external onlyOwner {
        botState.strategy = _newStrategy;
        emit StrategyUpdated(_newStrategy);
    }
    
    /**
     * @dev Pause bot
     */
    function pauseBot() external onlyOwner {
        botState.status = BotStatus.PAUSED;
        emit BotStatusChanged(BotStatus.PAUSED);
    }
    
    /**
     * @dev Resume bot
     */
    function resumeBot() external onlyOwner {
        botState.status = BotStatus.ACTIVE;
        emit BotStatusChanged(BotStatus.ACTIVE);
    }
    
    /**
     * @dev Stop bot permanently
     */
    function stopBot() external onlyOwner {
        botState.status = BotStatus.STOPPED;
        emit BotStatusChanged(BotStatus.STOPPED);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get trade history length
     * @return Number of trades
     */
    function getTradeCount() external view returns (uint256) {
        return tradeHistory.length;
    }
    
    /**
     * @dev Get trade by index
     * @param _index Trade index
     * @return Trade data
     */
    function getTrade(uint256 _index) external view returns (Trade memory) {
        require(_index < tradeHistory.length, "Invalid index");
        return tradeHistory[_index];
    }
    
    /**
     * @dev Get bot state
     * @return Current bot state
     */
    function getBotState() external view returns (BotState memory) {
        return botState;
    }
    
    /**
     * @dev Get token balance
     * @param _token Token address
     * @return Balance amount
     */
    function getBalance(address _token) external view returns (uint256) {
        return tokenBalance[_token];
    }

    /**
     * @dev Convenience view to expose a few bot parameters for testing
     */
    function getStrategyAndParams() external view returns (StrategyType strategy, uint256 tradeAmount, uint256 minProfit, uint256 maxDrawdown) {
        strategy = botState.strategy;
        tradeAmount = botState.tradeAmount;
        minProfit = botState.minProfitTarget;
        maxDrawdown = botState.maxDrawdown;
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Estimate swap amount (placeholder)
     * @param _amountIn Input amount
     * @return Estimated output amount
     */
    function _estimateSwapAmount(uint256 _amountIn) internal pure returns (uint256) {
        // In production, integrate with oracle or price feed
        return (_amountIn * 99) / 100; // Simplified: 1% slippage
    }
    
    /**
     * @dev Calculate PnL for a trade
     * @param _amountIn Input amount
     * @param _amountOut Output amount
     * @return PnL in basis points
     */
    function _calculatePnL(uint256 _amountIn, uint256 _amountOut) internal pure returns (int256) {
        if (_amountOut >= _amountIn) {
            return int256((_amountOut - _amountIn) * 10000 / _amountIn);
        } else {
            return -int256((_amountIn - _amountOut) * 10000 / _amountIn);
        }
    }
}
