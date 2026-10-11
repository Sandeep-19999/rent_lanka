export function isAdminProfile(profile) {
  return !!profile && profile.role === 'admin';
}

export function safeReturnPath(path) {
  return typeof path === 'string' && /^\/(dashboard|payments|transactions|refunds|withdrawals)(\/|$|\?)/.test(path)
    ? path : '/dashboard';
}
