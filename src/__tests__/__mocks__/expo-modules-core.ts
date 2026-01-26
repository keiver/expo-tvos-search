/**
 * Mock expo-modules-core module for testing
 * Uses global state to persist mock values across module resets
 */

declare global {
  var __mockNativeViewAvailable: boolean;
}

// Only initialize if not already set (allows persistence across module resets)
if (globalThis.__mockNativeViewAvailable === undefined) {
  globalThis.__mockNativeViewAvailable = false;
}

export const requireNativeViewManager = (_name: string) => {
  if (globalThis.__mockNativeViewAvailable) {
    // Return a mock component function
    return () => null;
  }
  return null;
};
