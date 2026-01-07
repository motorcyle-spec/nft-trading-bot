import * as redis from 'redis'

const client = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
})

client.on('error', (err) => console.error('Redis Client Error', err))

export async function connectRedis() {
  if (!client.isOpen) {
    await client.connect()
  }
  return client
}

export async function cacheBotState(tokenId: string, state: any, ttl: number = 60) {
  const key = `bot:${tokenId}`
  await client.setEx(key, ttl, JSON.stringify(state))
}

export async function getBotState(tokenId: string) {
  const key = `bot:${tokenId}`
  const data = await client.get(key)
  return data ? JSON.parse(data) : null
}

export default client
