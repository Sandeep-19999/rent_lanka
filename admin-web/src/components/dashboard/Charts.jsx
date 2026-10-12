import { Area, AreaChart, Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { formatCurrency, formatMethod, formatStatus } from '../../utils/format.js';
import { EmptyState } from '../common/Feedback.jsx';

const palette = ['var(--color-primary)', 'var(--color-info)', 'var(--color-warning)', 'var(--color-text-subtle)'];
const statusColors = { paid: 'var(--color-success)', pay_on_pickup: 'var(--color-warning)', refunded: 'var(--color-info)' };
function ChartTooltip({ active, payload, label, currency = false, labelFormatter }) {
  if (!active || !payload?.length) return null;
  return <div className="chart-tooltip"><strong>{labelFormatter ? labelFormatter(label) : label}</strong>{payload.map((item, index) => <div key={index}><span style={{ background: item.color || item.payload?.fill || 'var(--color-info)' }} /><span>{item.name}</span><b>{currency ? formatCurrency(item.value) : item.value}</b></div>)}</div>;
}
const shortAmount = (value) => value >= 1000000 ? `${(value / 1000000).toFixed(1)}m` : value >= 1000 ? `${(value / 1000).toFixed(0)}k` : value;

export function VolumeChart({ data, empty }) {
  if (empty) return <EmptyState compact title="Payment activity starts here" description="Paid charges and recorded refunds will form this chart as bookings are made." />;
  return <div className="chart-container" role="img" aria-label="LKR paid charge volume and refunded amounts over time">
    <ResponsiveContainer width="100%" height={280} minWidth={0} initialDimension={{ width: 600, height: 280 }}>
      <AreaChart data={data} margin={{ top: 15, right: 8, left: 0, bottom: 4 }}>
        <defs><linearGradient id="paidFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="var(--color-primary)" stopOpacity={.24} /><stop offset="100%" stopColor="var(--color-primary)" stopOpacity={0} /></linearGradient></defs>
        <CartesianGrid stroke="var(--chart-grid)" vertical={false} />
        <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} minTickGap={26} dy={9} />
        <YAxis axisLine={false} tickLine={false} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} tickFormatter={shortAmount} width={44} />
        <Tooltip content={<ChartTooltip currency />} />
        <Area type="monotone" dataKey="paid" name="Paid charges" stroke="var(--color-primary)" strokeWidth={2.5} fill="url(#paidFill)" isAnimationActive={false} />
        <Area type="monotone" dataKey="refunded" name="Refunds" stroke="var(--color-info)" strokeWidth={1.7} fill="transparent" strokeDasharray="4 4" isAnimationActive={false} />
      </AreaChart>
    </ResponsiveContainer>
  </div>;
}

export function StatusChart({ data, total }) {
  if (!total) return <EmptyState compact title="No statuses to show" description="Payment statuses will appear with your first records." />;
  return <div className="status-chart-content"><div className="donut-container" role="img" aria-label="Payment record counts by stored status">
    <ResponsiveContainer width="100%" height={194} minWidth={0} initialDimension={{ width: 280, height: 194 }}><PieChart><Pie data={data} dataKey="value" nameKey="name" innerRadius={64} outerRadius={82} paddingAngle={3} stroke="transparent" isAnimationActive={false}>
      {data.map((entry, index) => <Cell key={entry.name} fill={statusColors[entry.name] || palette[index % palette.length]} />)}
    </Pie><Tooltip formatter={(value, name) => [value, formatStatus(name)]} contentStyle={{ background: 'var(--color-background-elevated)', border: '1px solid var(--color-border)', borderRadius: 12, color: 'var(--color-text)', boxShadow: 'var(--shadow-md)' }} itemStyle={{ color: 'var(--color-text)' }} /></PieChart></ResponsiveContainer>
    <div className="donut-center"><strong>{total}</strong><span>records</span></div></div>
    <ul className="chart-legend">{data.map((entry, index) => <li key={entry.name}><span className="legend-dot" style={{ background: statusColors[entry.name] || palette[index % palette.length] }} /><span>{formatStatus(entry.name)}</span><strong>{entry.value}</strong><small>{Math.round(entry.value / total * 100)}%</small></li>)}</ul>
  </div>;
}

export function MethodChart({ data }) {
  if (!data.length) return <EmptyState compact title="No payment methods yet" description="Methods are calculated from original charge records." />;
  const chartData = data.map((entry) => ({ ...entry, label: formatMethod(entry.name) }));
  return <div className="method-chart" role="img" aria-label="Original charge record counts by payment method"><ResponsiveContainer width="100%" height={Math.max(150, data.length * 46)} minWidth={0} initialDimension={{ width: 650, height: 150 }}>
    <BarChart layout="vertical" data={chartData} margin={{ left: 4, right: 24, top: 8, bottom: 8 }}><CartesianGrid stroke="var(--chart-grid)" horizontal={false} />
      <XAxis type="number" axisLine={false} tickLine={false} allowDecimals={false} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} />
      <YAxis type="category" dataKey="label" axisLine={false} tickLine={false} width={112} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} />
      <Tooltip cursor={{ fill: 'var(--surface-soft)' }} content={<ChartTooltip />} />
      <Bar dataKey="value" name="Charge records" radius={[0, 5, 5, 0]} barSize={15} isAnimationActive={false}>{data.map((entry, index) => <Cell key={entry.name} fill={palette[index % palette.length]} />)}</Bar>
    </BarChart>
  </ResponsiveContainer></div>;
}
