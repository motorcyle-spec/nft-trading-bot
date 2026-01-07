import { BotDeployed } from '../generated/BotFactory/BotFactory'
import { Bot, Owner } from '../generated/schema'
import { BigInt } from '@graphprotocol/graph-ts'

export function handleBotDeployed(event: BotDeployed): void {
  const bot = new Bot(event.params.tokenId.toString())
  bot.address = event.params.botAddress.toHexString()
  bot.owner = event.params.owner.toHexString()
  bot.tokenId = event.params.tokenId
  bot.name = 'Bot #' + event.params.tokenId.toString()
  bot.strategy = 'UNKNOWN'
  bot.status = 'ACTIVE'
  bot.baseToken = ''
  bot.quoteToken = ''
  bot.tradeAmount = BigInt.zero()
  bot.minProfitTarget = 0
  bot.maxDrawdown = 0
  bot.totalTrades = 0
  bot.totalPnL = BigInt.zero()
  bot.createdAt = event.block.timestamp
  bot.updatedAt = event.block.timestamp
  bot.save()

  // Update or create owner
  const ownerId = event.params.owner.toHexString()
  let owner = Owner.load(ownerId)
  if (!owner) {
    owner = new Owner(ownerId)
    owner.address = event.params.owner.toHexString()
    owner.botCount = 0
    owner.totalPnL = BigInt.zero()
  }
  owner.botCount += 1
  owner.save()
}
