import { useReducer } from 'react';
import { photoState } from '../../utils/photoState.js';
import { imageSource } from '../../utils/platform.js';
export default function StoredPhoto({ src, alt, enlarge = false }) {
  const safe = imageSource(src);
  return <Photo key={safe} src={safe} alt={alt} enlarge={enlarge} />;
}
function Photo({ src, alt, enlarge }) {
  const [state, dispatch] = useReducer(photoState, 'loading');
  if (!src || state === 'error') return <div className="photo-placeholder" role="status">{src ? 'Photo unavailable' : 'No photo uploaded'}</div>;
  const photo = <><img src={src} alt={alt} loading="lazy" referrerPolicy="no-referrer" onLoad={() => dispatch('load')} onError={() => dispatch('error')} />{state === 'loading' && <span role="status" className="photo-loading">Loading photo...</span>}</>;
  return enlarge ? <a className="stored-photo" href={src} target="_blank" rel="noopener noreferrer" aria-label={`Open full photo: ${alt}`}>{photo}</a> : <div className="stored-photo">{photo}</div>;
}
