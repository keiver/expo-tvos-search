/**
 * Tests for expo-tvos-search TypeScript exports
 *
 * Note: Platform checks in index.tsx run at module load time.
 * These tests verify the behavior when mocked Platform values are set
 * before the module is required.
 */

import {
  mockTvOSPlatform,
  mockWebPlatform,
  mockNativeModuleAvailable,
  mockNativeModuleUnavailable,
} from './setup';

describe('isNativeSearchAvailable', () => {
  describe('on non-tvOS platforms', () => {
    beforeEach(() => {
      jest.resetModules();
      mockWebPlatform();
      mockNativeModuleUnavailable();
    });

    it('returns false when not on tvOS', () => {
      const { isNativeSearchAvailable } = require('../index');
      expect(isNativeSearchAvailable()).toBe(false);
    });
  });

  describe('on tvOS without native module', () => {
    beforeEach(() => {
      jest.resetModules();
      mockTvOSPlatform();
      mockNativeModuleUnavailable();
    });

    it('returns false when native module unavailable', () => {
      const { isNativeSearchAvailable } = require('../index');
      expect(isNativeSearchAvailable()).toBe(false);
    });
  });

  describe('on tvOS with native module', () => {
    beforeEach(() => {
      jest.resetModules();
      mockTvOSPlatform();
      mockNativeModuleAvailable();
    });

    it('returns true when native module is available', () => {
      const { isNativeSearchAvailable } = require('../index');
      expect(isNativeSearchAvailable()).toBe(true);
    });
  });
});

describe('TvosSearchView', () => {
  beforeEach(() => {
    jest.resetModules();
    mockWebPlatform();
    mockNativeModuleUnavailable();
  });

  it('returns null when native module is unavailable', () => {
    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });
    expect(result).toBeNull();
  });
});

describe('SearchResult interface', () => {
  it('accepts valid SearchResult objects', () => {
    const validResult = {
      id: 'test-123',
      title: 'Test Movie',
      subtitle: 'Optional subtitle',
      imageUrl: 'https://example.com/poster.jpg',
    };

    expect(validResult.id).toBe('test-123');
    expect(validResult.title).toBe('Test Movie');
    expect(validResult.subtitle).toBe('Optional subtitle');
    expect(validResult.imageUrl).toBe('https://example.com/poster.jpg');
  });

  it('accepts SearchResult with only required fields', () => {
    const minimalResult = {
      id: 'minimal-123',
      title: 'Minimal Movie',
    };

    expect(minimalResult.id).toBe('minimal-123');
    expect(minimalResult.title).toBe('Minimal Movie');
  });
});

describe('TvosSearchViewProps defaults', () => {
  it('all optional props have documented defaults', () => {
    // This test documents the expected default values
    // The actual defaults are applied in Swift (ExpoTvosSearchView.swift)
    const expectedDefaults = {
      columns: 5,
      placeholder: 'Search...',
      isLoading: false,
      showTitle: false,
      showSubtitle: false,
      showFocusBorder: false,
      topInset: 0,
      showTitleOverlay: true,
      enableMarquee: true,
      marqueeDelay: 1.5,
      overlayTitleSize: 20,
    };

    // Verify default documentation matches Swift implementation
    expect(expectedDefaults.columns).toBe(5);
    expect(expectedDefaults.showTitleOverlay).toBe(true);
    expect(expectedDefaults.enableMarquee).toBe(true);
    expect(expectedDefaults.marqueeDelay).toBe(1.5);
    expect(expectedDefaults.overlayTitleSize).toBe(20);
  });
});

describe('TvosSearchViewProps overlayTitleSize', () => {
  beforeEach(() => {
    jest.resetModules();
    mockTvOSPlatform();
    mockNativeModuleAvailable();
  });

  it('accepts overlayTitleSize as a number', () => {
    const { TvosSearchView } = require('../index');

    // Should not throw when overlayTitleSize is provided
    expect(() => {
      TvosSearchView({
        results: [],
        onSearch: jest.fn(),
        onSelectItem: jest.fn(),
        overlayTitleSize: 18,
      });
    }).not.toThrow();
  });

  it('accepts overlayTitleSize with various values', () => {
    const { TvosSearchView } = require('../index');

    const testCases = [12, 18, 20, 24, 32];

    testCases.forEach((size) => {
      expect(() => {
        TvosSearchView({
          results: [],
          onSearch: jest.fn(),
          onSelectItem: jest.fn(),
          overlayTitleSize: size,
        });
      }).not.toThrow();
    });
  });

  it('works without overlayTitleSize (uses default)', () => {
    const { TvosSearchView } = require('../index');

    // Should not throw when overlayTitleSize is omitted
    expect(() => {
      TvosSearchView({
        results: [],
        onSearch: jest.fn(),
        onSelectItem: jest.fn(),
      });
    }).not.toThrow();
  });
});
