// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TradingBot.sol";

contract TradingBotTest is Test {
    TradingBot public bot;
    address public owner = address(0x1);
    address public token1 = address(0x2);
    address public token2 = address(0x3);
    
    function setUp() public {
        bot = new TradingBot();
        vm.prank(address(this));
    }
    
    function testInitialize() public {
        bot.initialize(
            "Test Bot",
            TradingBot.StrategyType.DCA,
            token1,
            token2,
            1 ether,
            500,  // 5% min profit
            2000  // 20% max drawdown
        );
        
        TradingBot.BotState memory state = bot.getBotState();
        assertEq(state.name, "Test Bot");
        assertEq(state.baseToken, token1);
        assertEq(state.quoteToken, token2);
    }
    
    function testBotPause() public {
        bot.initialize(
            "Test Bot",
            TradingBot.StrategyType.DCA,
            token1,
            token2,
            1 ether,
            500,
            2000
        );
        
        bot.pauseBot();
        TradingBot.BotState memory state = bot.getBotState();
        assertEq(uint(state.status), uint(TradingBot.BotStatus.PAUSED));
    }
    
    function testBotResume() public {
        bot.initialize(
            "Test Bot",
            TradingBot.StrategyType.DCA,
            token1,
            token2,
            1 ether,
            500,
            2000
        );
        
        bot.pauseBot();
        bot.resumeBot();
        
        TradingBot.BotState memory state = bot.getBotState();
        assertEq(uint(state.status), uint(TradingBot.BotStatus.ACTIVE));
    }
}
