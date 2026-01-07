import { TradeExecuted } from '../generated/TradingBot/TradingBot'
import { Trade, Bot } from '../generated/schema'

export function handleTradeExecuted(event: TradeExecuted): void {
  const trade = new Trade(event.transaction.hash.toHexString() + '-' + event.logIndex.toString())
  trade.botAddress = event.address.toHexString()
  trade.timestamp = event.block.timestamp
  trade.tokenIn = event.params.tokenIn.toHexString()
  trade.tokenOut = event.params.tokenOut.toHexString()
  trade.amountIn = event.params.amountIn
  trade.amountOut = event.params.amountOut
  trade.pnl = event.params.pnl
  trade.save()

  // Update bot stats
  const bot = Bot.load(event.address.toHexString())
  if (bot) {
    bot.totalTrades += 1
    bot.totalPnL = bot.totalPnL.plus(event.params.pnl)
    bot.updatedAt = event.block.timestamp
    bot.save()
  }
}
