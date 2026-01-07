import { create } from 'zustand'

interface BotState {
  bots: any[]
  loading: boolean
  error: string | null
}

export const useBotStore = create<BotState>((set) => ({
  bots: [],
  loading: false,
  error: null,
}))
