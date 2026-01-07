// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TradingBot.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor() ERC20("Mock", "MCK") {}
    function mint(address to, uint256 amount) external { _mint(to, amount); }
}

contract TradingBotFuzzTest is Test {
    TradingBot bot;
    address owner = address(0x1);

    function setUp() public {
        vm.prank(owner);
        bot = new TradingBot();
    }

    /// @notice Fuzz the initialize inputs and assert stored state
    function testInitializeFuzz(uint256 tradeAmount, uint256 minProfit, uint256 maxDrawdown) public {
        vm.assume(tradeAmount > 0 && tradeAmount < type(uint256).max / 2);
        vm.assume(minProfit <= 10000);
        vm.assume(maxDrawdown <= 10000);

        vm.prank(owner); // factory is the deployer in constructor
        bot.initialize(
            "fuzz",
            TradingBot.StrategyType.DCA,
            address(0x10),
            address(0x20),
            tradeAmount,
            minProfit,
            maxDrawdown
        );

        (TradingBot.StrategyType strategy, uint256 tradeAmountRead, uint256 minProfitRead, uint256 maxDrawdownRead) = bot.getStrategyAndParams();

        assertEq(uint256(strategy), uint256(TradingBot.StrategyType.DCA));
        assertEq(tradeAmountRead, tradeAmount);
        assertEq(minProfitRead, minProfit);
        assertEq(maxDrawdownRead, maxDrawdown);
    }

    /// @notice Fuzz deposit/withdraw flows using a simple ERC20
    function testDepositWithdrawFuzz(uint256 amount) public {
        vm.assume(amount > 1 && amount < 1e36);

        // Deploy fresh bot as owner
        vm.prank(owner);
        TradingBot b = new TradingBot();

        ERC20Mock token = new ERC20Mock();
        token.mint(owner, amount);

        vm.prank(owner);
        token.approve(address(b), amount);

        vm.prank(owner);
        b.depositFunds(address(token), amount);

        assertEq(b.tokenBalance(address(token)), amount);

        uint256 half = amount / 2;
        vm.prank(owner);
        b.withdrawFunds(address(token), half);

        assertEq(b.tokenBalance(address(token)), amount - half);
    }
}
