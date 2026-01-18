/** @type {import('jest').Config} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/src/__tests__/**/*.test.ts?(x)'],
  testPathIgnorePatterns: ['/node_modules/', '/build/'],
  modulePathIgnorePatterns: ['<rootDir>/build/'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  setupFilesAfterEnv: ['<rootDir>/src/__tests__/setup.ts'],
  collectCoverageFrom: ['src/**/*.{ts,tsx}', '!src/__tests__/**'],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleNameMapper: {
    '^react-native$': '<rootDir>/src/__tests__/__mocks__/react-native.ts',
    '^expo-modules-core$': '<rootDir>/src/__tests__/__mocks__/expo-modules-core.ts',
  },
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        tsconfig: {
          jsx: 'react',
          esModuleInterop: true,
          moduleResolution: 'node',
          skipLibCheck: true,
          isolatedModules: true,
        },
      },
    ],
  },
};
