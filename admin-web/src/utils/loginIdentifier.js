// Firebase authenticates the username alias through the existing admin account.
export function loginEmail(identifier) {
  const value = identifier.trim();
  return value.toLowerCase() === 'admin-sithuli' ? 'admin@rentlanka.example' : value;
}
