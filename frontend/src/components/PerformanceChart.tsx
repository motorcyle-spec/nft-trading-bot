import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

interface PerformanceChartProps {
  data?: any[]
}

export function PerformanceChart({ data = [] }: PerformanceChartProps) {
  const mockData = [
    { date: 'Jan 1', pnl: 100 },
    { date: 'Jan 2', pnl: 150 },
    { date: 'Jan 3', pnl: 120 },
    { date: 'Jan 4', pnl: 200 },
    { date: 'Jan 5', pnl: 180 },
  ]

  return (
    <div className="bg-slate-700 rounded-lg p-6 border border-slate-600">
      <h3 className="text-lg font-semibold text-white mb-4">PnL Performance</h3>
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data.length > 0 ? data : mockData}>
          <CartesianGrid strokeDasharray="3 3" stroke="#475569" />
          <XAxis dataKey="date" stroke="#94a3b8" />
          <YAxis stroke="#94a3b8" />
          <Tooltip contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #475569' }} />
          <Legend />
          <Bar dataKey="pnl" fill="#8b5cf6" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
