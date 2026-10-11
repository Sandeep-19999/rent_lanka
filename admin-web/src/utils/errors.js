export function errorMessage(error, fallback = 'Something went wrong. Please try again.') {
  const code = error?.code?.replace(/^auth\//, '');
  const messages = {
    'permission-denied': 'Your account does not have permission to access this data. Ask the project administrator to review Firestore rules.',
    unavailable: 'Unable to reach Firebase. Check your connection and try again.',
    'network-request-failed': 'Unable to connect. Check your internet connection and try again.',
    'invalid-credential': 'The email or password is incorrect.',
    'wrong-password': 'The email or password is incorrect.',
    'user-not-found': 'The email or password is incorrect.',
    'invalid-email': 'Enter a valid email address.',
    'too-many-requests': 'Too many attempts. Please wait a moment before trying again.',
    'user-disabled': 'This account has been disabled. Contact the project administrator.',
    'operation-not-allowed': 'Email and password login is not enabled for this Firebase project.',
    'auth/invalid-api-key': 'The Firebase configuration is invalid. Review the local environment file.',
    'invalid-api-key': 'The Firebase configuration is invalid. Review the local environment file.',
    'unauthenticated': 'Your session has expired. Please sign in again.',
  };
  return messages[code] || (error?.name === 'RefundError' ? error.message : fallback);
}
