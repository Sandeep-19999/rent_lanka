export default function StatCard({ label, value, description, icon: Icon, tone = 'neutral' }) {
  return <article className={`glass stat-card stat-${tone}`}><div className="stat-top"><span>{label}</span><span className="stat-icon"><Icon size={18} /></span></div>
    <strong className="stat-value">{value}</strong><p>{description}</p></article>;
}
