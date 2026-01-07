import { WagmiConfig, configureChains, createConfig } from 'wagmi'
import { sepolia, mainnet } from 'viem/chains'
import { publicProvider } from 'wagmi/providers/public'
import { ConnectButton, RainbowKitProvider } from '@rainbow-me/rainbowkit'
import '@rainbow-me/rainbowkit/styles.css'
import './App.css'

const { chains, publicClient } = configureChains(
  [sepolia, mainnet],
  [publicProvider()],
)

const config = createConfig({
  autoConnect: true,
  publicClient,
})

function App() {
  return (
    <WagmiConfig config={config}>
      <RainbowKitProvider chains={chains}>
        <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
          <header className="bg-slate-800 border-b border-slate-700">
            <div className="max-w-7xl mx-auto px-4 py-6 flex justify-between items-center">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg"></div>
                <h1 className="text-2xl font-bold text-white">Trading Bot System</h1>
              </div>
              <ConnectButton />
            </div>
          </header>

          <main className="max-w-7xl mx-auto px-4 py-12">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Dashboard Cards */}
              <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
                <h2 className="text-xl font-semibold text-white mb-4">Active Bots</h2>
                <p className="text-4xl font-bold text-purple-400">0</p>
              </div>

              <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
                <h2 className="text-xl font-semibold text-white mb-4">Total PnL</h2>
                <p className="text-4xl font-bold text-green-400">$0.00</p>
              </div>

              <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
                <h2 className="text-xl font-semibold text-white mb-4">Total Trades</h2>
                <p className="text-4xl font-bold text-blue-400">0</p>
              </div>
            </div>

            <div className="mt-8 bg-slate-700 rounded-lg p-6 border border-slate-600">
              <h2 className="text-xl font-semibold text-white mb-4">Create New Bot</h2>
              <p className="text-slate-300">Connect your wallet to deploy a new trading bot</p>
            </div>
          </main>
        </div>
      </RainbowKitProvider>
    </WagmiConfig>
  )
}

export default App
