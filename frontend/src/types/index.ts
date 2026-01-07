export interface BotState {
  id: string
  name: string
  owner: string
  strategy: 'DCA' | 'ARBITRAGE' | 'CUSTOM'
  status: 'ACTIVE' | 'PAUSED' | 'STOPPED'
  baseToken: string
  quoteToken: string
  tradeAmount: bigint
  minProfitTarget: number
  maxDrawdown: number
  totalTrades: number
  totalPnL: number
  createdAt: number
}

export interface Trade {
  timestamp: number
  tokenIn: string
  tokenOut: string
  amountIn: bigint
  amountOut: bigint
  pnl: number
}

export interface ContractAddresses {
  factory: string
  registry: string
  nft: string
  wallet: string
}
