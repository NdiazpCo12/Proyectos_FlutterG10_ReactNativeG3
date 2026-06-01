module.exports = {
  preset: 'jest-expo',
  transformIgnorePatterns: [
    'node_modules/(?!(jest-expo|react-native|@react-native|expo|@expo|@unimodules|expo-modules-core|@react-navigation|lucide-react-native|papaparse|react-native-svg|react-native-screens|react-native-safe-area-context|@react-native-async-storage)/)',
  ],
  setupFiles: ['./jest.setup.js'],
  moduleNameMapper: {
    '^@react-native-async-storage/async-storage$': '<rootDir>/__mocks__/@react-native-async-storage/async-storage.js',
  },
};
