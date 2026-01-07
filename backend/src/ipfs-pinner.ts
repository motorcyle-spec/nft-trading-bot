import axios from 'axios'

const PINATA_API_KEY = process.env.PINATA_API_KEY || ''
const PINATA_API_SECRET = process.env.PINATA_API_SECRET || ''
const PINATA_BASE_URL = 'https://api.pinata.cloud'

export interface BotMetadata {
  name: string
  description: string
  image: string
  attributes: {
    strategy: string
    totalTrades: number
    pnl: number
  }
}

export async function pinMetadata(metadata: BotMetadata, filename: string) {
  try {
    const response = await axios.post(`${PINATA_BASE_URL}/pinning/pinJSONToIPFS`, metadata, {
      headers: {
        'pinata_api_key': PINATA_API_KEY,
        'pinata_secret_api_key': PINATA_API_SECRET,
        'Content-Type': 'application/json',
      },
    })

    const ipfsHash = response.data.IpfsHash
    console.log(`Metadata pinned to IPFS: ipfs://${ipfsHash}`)
    return `ipfs://${ipfsHash}`
  } catch (error) {
    console.error('Pinata Error:', error)
    throw error
  }
}

export async function updateBotMetadata(tokenId: string, metadata: BotMetadata) {
  return pinMetadata(metadata, `bot-${tokenId}`)
}

export default {
  pinMetadata,
  updateBotMetadata,
}
