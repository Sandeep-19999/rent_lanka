import { Link, useParams } from 'react-router-dom';
import { useDocument } from '../hooks/useDocument.js';
import { useCollection } from '../hooks/useCollection.js';
import { normalizeUser, normalizeEquipment, normalizeBooking } from '../utils/platform.js';
import { formatDate, formatCurrency } from '../utils/format.js';
import { EmptyState, PageHeading } from '../components/common/Feedback.jsx';
import { Bookings, Details, RecordState } from '../components/common/PlatformRecords.jsx';
import StoredPhoto from '../components/common/StoredPhoto.jsx';
export default function UserDetailsPage() {
  const { userId } = useParams(); const state = useDocument('users',userId);
  const equipment = useCollection('equipment',normalizeEquipment,'providerId',userId);
  const provided = useCollection('rental_requests',normalizeBooking,'providerId',userId);
  const rented = useCollection('rental_requests',normalizeBooking,'playerId',userId);
  const row = normalizeUser(userId,state.data || {});
  const bookings = { rows: [...new Map([...provided.rows,...rented.rows].map(r => [r.id,r])).values()], loading: provided.loading || rented.loading, error: provided.error || rented.error, retry: () => { provided.retry(); rented.retry(); } };
  return <><PageHeading eyebrow="PLATFORM ADMINISTRATION" title={row.name || 'User details'} description="Profile and rental activity"><Link className="button secondary" to="/users">Back to users</Link></PageHeading><RecordState state={state}>{state.missing ? <EmptyState title="User not found" description="This profile may no longer exist." /> : <><section className="glass platform-panel"><div className="profile-photo"><StoredPhoto src={row.photoUrl} alt={row.name || 'User profile'} /></div><Details entries={[["User ID",row.id],["Name",row.name],["Email",row.email],["Phone",row.phone],["Role",row.role],["Location",row.location],["Verification",row.isVerified == null ? '' : row.isVerified ? 'Verified' : 'Unverified'],["Joined",formatDate(row.createdAt)]]} /></section><section className="glass platform-panel"><h2>Equipment listings</h2><RecordState state={equipment}>{!equipment.rows.length ? <EmptyState compact title="No equipment listings" description="No listings are linked to this user." /> : <ul className="related-records">{equipment.rows.map(e => <li key={e.id}><Link to={`/equipment/${encodeURIComponent(e.id)}`}>{e.name || e.id}</Link><span>{e.status || 'Unknown'} - {formatCurrency(e.pricePerDay)} / day</span></li>)}</ul>}</RecordState></section><Bookings state={bookings} /></>}</RecordState></>;
}
