const dbName =
  process.env.EXPO_PUBLIC_ROBLE_DB_NAME ?? 'peerassessment_3320f2054b';

export const robleConfig = {
  dbName,
  authBaseUrl:
    process.env.EXPO_PUBLIC_ROBLE_AUTH_BASE_URL ??
    `https://roble-api.openlab.uninorte.edu.co/auth/${dbName}`,
  dbBaseUrl:
    process.env.EXPO_PUBLIC_ROBLE_DB_BASE_URL ??
    `https://roble-api.openlab.uninorte.edu.co/database/${dbName}`,
};
