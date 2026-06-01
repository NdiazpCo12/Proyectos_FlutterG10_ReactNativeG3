// Async Storage is auto-mocked via __mocks__/@react-native-async-storage/async-storage.js

jest.mock('./src/config/robleConfig', () => ({
  robleConfig: {
    authBaseUrl: 'https://test.roble.app',
    dbBaseUrl: 'https://test.roble.app/database/test-db',
    dbName: 'test-db',
  },
}));
