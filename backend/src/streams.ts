import Axios from 'axios'

const QUICKNODE_RPC = process.env.QUICKNODE_RPC_URL || 'https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY'
const QUICKNODE_WS = process.env.QUICKNODE_WS_URL || 'wss://eth-sepolia.g.alchemy.com/v2/YOUR_KEY'

export class QuickNodeClient {
  private rpcUrl: string
  private wsUrl: string

  constructor(rpcUrl: string = QUICKNODE_RPC, wsUrl: string = QUICKNODE_WS) {
    this.rpcUrl = rpcUrl
    this.wsUrl = wsUrl
  }

  async callRPC(method: string, params: any[] = []) {
    try {
      const response = await Axios.post(this.rpcUrl, {
        jsonrpc: '2.0',
        method,
        params,
        id: 1,
      })
      return response.data.result
    } catch (error) {
      console.error('RPC Error:', error)
      throw error
    }
  }

  async getBlockNumber() {
    return this.callRPC('eth_blockNumber')
  }

  async getBalance(address: string) {
    return this.callRPC('eth_getBalance', [address, 'latest'])
  }

  async getTransaction(txHash: string) {
    return this.callRPC('eth_getTransactionByHash', [txHash])
  }

  getWebSocketUrl() {
    return this.wsUrl
  }
}

export default new QuickNodeClient()
