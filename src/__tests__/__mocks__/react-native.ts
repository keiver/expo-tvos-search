/**
 * Mock react-native module for testing
 * Uses global state to persist mock values across module resets
 */

// Global state for Platform mock - only initialize if not already set
declare global {
  var __mockPlatformOS: 'ios' | 'android' | 'web';
  var __mockPlatformIsTV: boolean;
}

// Only initialize if not already set (allows persistence across module resets)
if (globalThis.__mockPlatformOS === undefined) {
  globalThis.__mockPlatformOS = 'web';
}
if (globalThis.__mockPlatformIsTV === undefined) {
  globalThis.__mockPlatformIsTV = false;
}

export const Platform = {
  get OS() {
    return globalThis.__mockPlatformOS;
  },
  set OS(value: 'ios' | 'android' | 'web') {
    globalThis.__mockPlatformOS = value;
  },
  get isTV() {
    return globalThis.__mockPlatformIsTV;
  },
  set isTV(value: boolean) {
    globalThis.__mockPlatformIsTV = value;
  },
  select: <T>(options: { ios?: T; android?: T; web?: T; default?: T }): T | undefined => {
    return options.default ?? options.web;
  },
};

export interface ViewStyle {
  flex?: number;
  [key: string]: unknown;
}
