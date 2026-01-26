/**
 * Mock expo-modules-core module for testing
 * Uses global state to persist mock values across module resets
 */

declare global {
  var __mockNativeViewAvailable: boolean;
  var __mockPrewarmFn: jest.Mock;
}

// Only initialize if not already set (allows persistence across module resets)
if (globalThis.__mockNativeViewAvailable === undefined) {
  globalThis.__mockNativeViewAvailable = false;
}
if (!globalThis.__mockPrewarmFn) {
  globalThis.__mockPrewarmFn = jest.fn();
}

export const requireNativeViewManager = (_name: string) => {
  if (globalThis.__mockNativeViewAvailable) {
    // Return a mock component function
    return () => null;
  }
  return null;
};

export const requireNativeModule = (_name: string) => {
  if (globalThis.__mockNativeViewAvailable) {
    return { prewarm: globalThis.__mockPrewarmFn };
  }
  return null;
};
