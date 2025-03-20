const ADMIN_DOMAINS = [
  'admin.com',
  'hotel.com',
  'ehotels.com'
];

export const isAdminDomain = (email: string): boolean => {
  const domain = email.split('@')[1];
  return ADMIN_DOMAINS.includes(domain);
}; 