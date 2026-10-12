import { Link, useParams } from 'react-router-dom';
import { useDocument } from '../hooks/useDocument.js';
import { useCollection } from '../hooks/useCollection.js';
import { normalizeEquipment, normalizeUser, normalizeBooking } from '../utils/platform.js';
import { formatDate, formatCurrency } from '../utils/format.js';
import { EmptyState, PageHeading } from '../components/common/Feedback.jsx';
import { Bookings, Details, RecordState } from '../components/common/PlatformRecords.jsx';
import StoredPhoto from '../components/common/StoredPhoto.jsx';
export default function EquipmentDetailsPage() {
  const { equipmentId } = useParams(); const state = useDocument('equipment',equipmentId);
  const row = normalizeEquipment(equipmentId,state.data || {});
  const provider = useDocument('users',row.providerId); const profile = normalizeUser(row.providerId,provider.data || {});
  const bookings = useCollection('rental_requests',normalizeBooking,'equipmentId',equipmentId);
  return <><PageHeading eyebrow="PLATFORM ADMINISTRATION" title={row.name || 'Listing details'} description="Equipment details and original uploaded photo"><Link className="button secondary" to="/equipment">Back to listings</Link></PageHeading><RecordState state={state}>{state.missing ? <EmptyState title="Listing not found" description="This equipment may no longer exist." /> : <><section className="glass platform-panel"><div className="listing-detail-grid"><div><StoredPhoto src={row.imageUrl} alt={row.name || 'Equipment photo'} enlarge /><p className="muted">Open the photo to view the original upload.</p></div><Details entries={[["Listing ID",row.id],["Category",row.category],["Brand",row.brand],["Size",row.size],["Condition",row.condition],["Price per day",formatCurrency(row.pricePerDay)],["Status",row.status],["Availability",row.isAvailable == null ? '' : row.isAvailable ? 'Available' : 'Unavailable'],["Location",row.location],["Created",formatDate(row.createdAt)]]} /></div><h2>Description</h2><p className="listing-description">{row.description || 'No description recorded.'}</p><h2>Unavailable dates</h2><p>{row.unavailableDates.join(', ') || 'No unavailable dates recorded.'}</p></section><section className="glass platform-panel"><h2>Provider</h2><RecordState state={provider}>{provider.missing ? <p>Provider profile not found.</p> : <Details entries={[["Provider",row.providerId ? <Link to={`/users/${encodeURIComponent(row.providerId)}`}>{profile.name || row.providerName || row.providerId}</Link> : 'Not recorded'],["Email",profile.email],["Phone",profile.phone],["Location",profile.location]]} />}</RecordState></section><Bookings state={bookings} /></>}</RecordState></>;
}
