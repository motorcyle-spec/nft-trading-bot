import { useAccount } from 'wagmi'
import { useState } from 'react'

export function BotCreationForm() {
  const { address, isConnected } = useAccount()
  const [botName, setBotName] = useState('')
  const [strategy, setStrategy] = useState('DCA')

  if (!isConnected) {
    return (
      <div className="bg-yellow-900 border border-yellow-600 rounded-lg p-4">
        <p className="text-yellow-100">Connect your wallet to create a bot</p>
      </div>
    )
  }

  return (
    <form className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-white mb-2">Bot Name</label>
        <input
          type="text"
          value={botName}
          onChange={(e) => setBotName(e.target.value)}
          placeholder="My Trading Bot"
          className="w-full px-4 py-2 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-purple-500"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-white mb-2">Strategy</label>
        <select
          value={strategy}
          onChange={(e) => setStrategy(e.target.value)}
          className="w-full px-4 py-2 bg-slate-800 border border-slate-600 rounded-lg text-white focus:outline-none focus:border-purple-500"
        >
          <option value="DCA">DCA (Dollar Cost Averaging)</option>
          <option value="ARBITRAGE">Arbitrage</option>
          <option value="CUSTOM">Custom</option>
        </select>
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-semibold py-2 rounded-lg transition-all"
      >
        Deploy Bot
      </button>
    </form>
  )
}
