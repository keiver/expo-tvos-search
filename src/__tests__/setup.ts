/**
 * Jest test setup - helper functions for platform mocking
 * Uses global state to persist mock values across module resets
 */

// Import mocks to initialize globals
import './__mocks__/react-native';
import './__mocks__/expo-modules-core';

// Helper to simulate tvOS platform
export function mockTvOSPlatform(): void {
  globalThis.__mockPlatformOS = 'ios';
  globalThis.__mockPlatformIsTV = true;
}

// Helper to simulate iOS (non-TV) platform
export function mockIOSPlatform(): void {
  globalThis.__mockPlatformOS = 'ios';
  globalThis.__mockPlatformIsTV = false;
}

// Helper to simulate web platform
export function mockWebPlatform(): void {
  globalThis.__mockPlatformOS = 'web';
  globalThis.__mockPlatformIsTV = false;
}

// Helper to simulate Android platform
export function mockAndroidPlatform(): void {
  globalThis.__mockPlatformOS = 'android';
  globalThis.__mockPlatformIsTV = false;
}

// Helper to mock native module as available
export function mockNativeModuleAvailable(): void {
  globalThis.__mockNativeViewAvailable = true;
}

// Helper to mock native module as unavailable
export function mockNativeModuleUnavailable(): void {
  globalThis.__mockNativeViewAvailable = false;
}

// Reset mocks between tests
beforeEach(() => {
  jest.resetModules();
  mockWebPlatform();
  mockNativeModuleUnavailable();
});
