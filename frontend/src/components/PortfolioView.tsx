import { useAccount } from 'wagmi'

export function PortfolioView() {
  const { address, isConnected } = useAccount()

  if (!isConnected) {
    return (
      <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
        <p className="text-slate-300">Connect wallet to view your portfolio</p>
      </div>
    )
  }

  return (
    <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
      <h2 className="text-xl font-semibold text-white mb-4">Your Bots</h2>
      <div className="text-slate-300">No bots deployed yet</div>
    </div>
  )
}
