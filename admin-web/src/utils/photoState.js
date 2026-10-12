export function photoState(state, event) {
  if (event === 'load') return 'loaded';
  if (event === 'error') return 'error';
  return state;
}
