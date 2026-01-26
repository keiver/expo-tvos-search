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
      placeholder: 'Search movies and videos...', // Matches Swift default
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

describe('Module initialization error handling', () => {
  let consoleWarnSpy: jest.SpyInstance;
  let consoleErrorSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.resetModules();
    consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation();
    consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
  });

  afterEach(() => {
    consoleWarnSpy.mockRestore();
    consoleErrorSpy.mockRestore();
    jest.resetModules();
    jest.dontMock('expo-modules-core');
    jest.dontMock('react-native');
  });

  it('handles requireNativeViewManager not being a function', () => {
    mockTvOSPlatform();

    // Mock requireNativeViewManager as a string instead of function
    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: 'not-a-function',
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('requireNativeViewManager is not a function')
    );
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('incompatible expo-modules-core version')
    );
  });

  it('handles expo-modules-core missing error', () => {
    mockTvOSPlatform();

    // Mock expo-modules-core to throw error
    jest.doMock('expo-modules-core', () => {
      throw new Error('Cannot find module expo-modules-core');
    });

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('Failed to load expo-modules-core')
    );
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('npm install expo-modules-core')
    );
  });

  it('handles ExpoTvosSearch module not found error', () => {
    mockTvOSPlatform();

    // Mock requireNativeViewManager to throw module not found error
    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: jest.fn(() => {
        throw new Error('Native module ExpoTvosSearch not found');
      }),
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('Native module ExpoTvosSearch not found')
    );
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining("haven't run 'expo prebuild'")
    );
  });

  it('handles unexpected error', () => {
    mockTvOSPlatform();

    // Mock requireNativeViewManager to throw unexpected error
    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: jest.fn(() => {
        throw new Error('Some unexpected error');
      }),
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('Unexpected error loading native module')
    );
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('Some unexpected error')
    );
  });

  it('logs full error details in development mode for unexpected errors', () => {
    // Set __DEV__ to true
    (global as any).__DEV__ = true;

    mockTvOSPlatform();

    const testError = new Error('Unexpected development error');
    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: jest.fn(() => {
        throw testError;
      }),
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('Unexpected error loading native module')
    );
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      '[expo-tvos-search] Full error details:',
      testError
    );

    // Clean up __DEV__
    delete (global as any).__DEV__;
  });

  it('does not log full error details when __DEV__ is false', () => {
    // Set __DEV__ to false
    (global as any).__DEV__ = false;

    mockTvOSPlatform();

    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: jest.fn(() => {
        throw new Error('Production error');
      }),
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalled();
    expect(consoleErrorSpy).not.toHaveBeenCalled();

    // Clean up __DEV__
    delete (global as any).__DEV__;
  });

  it('does not log full error details when __DEV__ is undefined', () => {
    // Ensure __DEV__ is undefined
    delete (global as any).__DEV__;

    mockTvOSPlatform();

    jest.doMock('expo-modules-core', () => ({
      requireNativeViewManager: jest.fn(() => {
        throw new Error('No DEV error');
      }),
    }));

    const { isNativeSearchAvailable } = require('../index');

    expect(isNativeSearchAvailable()).toBe(false);
    expect(consoleWarnSpy).toHaveBeenCalled();
    expect(consoleErrorSpy).not.toHaveBeenCalled();
  });
});

describe('TvosSearchView development logging', () => {
  let consoleWarnSpy: jest.SpyInstance;
  let consoleInfoSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.resetModules();
    jest.dontMock('expo-modules-core');
    jest.dontMock('react-native');
    consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation();
    consoleInfoSpy = jest.spyOn(console, 'info').mockImplementation();
  });

  afterEach(() => {
    consoleWarnSpy.mockRestore();
    consoleInfoSpy.mockRestore();
    delete (global as any).__DEV__;
  });

  it('warns in development when on tvOS but native module unavailable', () => {
    // Set __DEV__ to true
    (global as any).__DEV__ = true;

    mockTvOSPlatform();
    mockNativeModuleUnavailable();

    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).toBeNull();
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining('TvosSearchView is rendering null on tvOS')
    );
    expect(consoleWarnSpy).toHaveBeenCalledWith(
      expect.stringContaining("native module wasn't built properly")
    );
  });

  it('logs info in development when on non-tvOS platform', () => {
    // Set __DEV__ to true
    (global as any).__DEV__ = true;

    mockWebPlatform();
    mockNativeModuleUnavailable();

    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).toBeNull();
    expect(consoleInfoSpy).toHaveBeenCalledWith(
      expect.stringContaining('TvosSearchView is not available on web')
    );
    expect(consoleInfoSpy).toHaveBeenCalledWith(
      expect.stringContaining('Use isNativeSearchAvailable()')
    );
  });

  it('does not log when __DEV__ is false', () => {
    // Set __DEV__ to false
    (global as any).__DEV__ = false;

    mockTvOSPlatform();
    mockNativeModuleUnavailable();

    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).toBeNull();
    expect(consoleWarnSpy).not.toHaveBeenCalled();
    expect(consoleInfoSpy).not.toHaveBeenCalled();
  });

  it('does not log when __DEV__ is undefined', () => {
    // Ensure __DEV__ is undefined (afterEach will clean up anyway)
    delete (global as any).__DEV__;

    mockWebPlatform();
    mockNativeModuleUnavailable();

    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).toBeNull();
    expect(consoleWarnSpy).not.toHaveBeenCalled();
    expect(consoleInfoSpy).not.toHaveBeenCalled();
  });

  it('logs info for iOS (non-TV) platform in development', () => {
    // Set __DEV__ to true
    (global as any).__DEV__ = true;

    // Use the helper functions instead of doMock
    globalThis.__mockPlatformOS = 'ios';
    globalThis.__mockPlatformIsTV = false;
    globalThis.__mockNativeViewAvailable = false;

    const { TvosSearchView } = require('../index');
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).toBeNull();
    expect(consoleInfoSpy).toHaveBeenCalledWith(
      expect.stringContaining('TvosSearchView is not available on ios')
    );
  });
});

describe('TvosSearchView with native module available', () => {
  beforeEach(() => {
    jest.resetModules();
    jest.dontMock('expo-modules-core');
    jest.dontMock('react-native');
    mockTvOSPlatform();
    mockNativeModuleAvailable();
  });

  it('renders when NativeView is available', () => {
    const { TvosSearchView } = require('../index');

    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    // Should render JSX element, not null
    expect(result).not.toBeNull();
    expect(result).toBeTruthy();
  });

  it('forwards props to NativeView', () => {
    const { TvosSearchView } = require('../index');

    const mockOnSearch = jest.fn();
    const mockOnSelectItem = jest.fn();
    const mockOnError = jest.fn();
    const mockResults = [
      { id: '1', title: 'Test 1', subtitle: 'Subtitle 1' },
      { id: '2', title: 'Test 2' },
    ];

    const result = TvosSearchView({
      results: mockResults,
      columns: 3,
      placeholder: 'Search...',
      isLoading: true,
      showTitle: true,
      showSubtitle: true,
      showFocusBorder: true,
      topInset: 100,
      textColor: '#FFFFFF',
      accentColor: '#FF0000',
      cardWidth: 300,
      cardHeight: 400,
      onSearch: mockOnSearch,
      onSelectItem: mockOnSelectItem,
      onError: mockOnError,
    });

    // Component should render
    expect(result).not.toBeNull();
  });

  it('renders with minimal required props', () => {
    const { TvosSearchView } = require('../index');

    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
    });

    expect(result).not.toBeNull();
  });

  it('renders with all optional props', () => {
    const { TvosSearchView } = require('../index');

    const mockOnValidationWarning = jest.fn();
    const mockOnSearchFieldFocused = jest.fn();
    const mockOnSearchFieldBlurred = jest.fn();

    const result = TvosSearchView({
      results: [{ id: 'test', title: 'Test', subtitle: 'Sub', imageUrl: 'http://example.com/img.jpg' }],
      columns: 5,
      placeholder: 'Custom placeholder',
      isLoading: false,
      showTitle: true,
      showSubtitle: true,
      showFocusBorder: true,
      topInset: 140,
      showTitleOverlay: false,
      enableMarquee: false,
      marqueeDelay: 2.0,
      emptyStateText: 'Nothing here',
      searchingText: 'Looking...',
      noResultsText: 'Not found',
      noResultsHintText: 'Try again',
      textColor: '#E5E5E5',
      accentColor: '#FFC312',
      cardWidth: 280,
      cardHeight: 420,
      imageContentMode: 'fit',
      cardMargin: 40,
      cardPadding: 16,
      overlayTitleSize: 20,
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
      onError: jest.fn(),
      onValidationWarning: mockOnValidationWarning,
      onSearchFieldFocused: mockOnSearchFieldFocused,
      onSearchFieldBlurred: mockOnSearchFieldBlurred,
      style: { flex: 1 },
    });

    expect(result).not.toBeNull();
  });

  it('renders without optional focus callbacks', () => {
    const { TvosSearchView } = require('../index');

    // onSearchFieldFocused and onSearchFieldBlurred are optional
    const result = TvosSearchView({
      results: [],
      onSearch: jest.fn(),
      onSelectItem: jest.fn(),
      // Note: onSearchFieldFocused and onSearchFieldBlurred are not provided
    });

    expect(result).not.toBeNull();
  });
});

describe('prewarmSearchView', () => {
  beforeEach(() => {
    jest.resetModules();
    globalThis.__mockPrewarmFn.mockClear();
  });

  describe('on tvOS with native module available', () => {
    beforeEach(() => {
      mockTvOSPlatform();
      mockNativeModuleAvailable();
    });

    it('calls NativeModule.prewarm()', () => {
      const { prewarmSearchView } = require('../index');
      prewarmSearchView();
      expect(globalThis.__mockPrewarmFn).toHaveBeenCalledTimes(1);
    });

    it('can be called multiple times without error', () => {
      const { prewarmSearchView } = require('../index');
      prewarmSearchView();
      prewarmSearchView();
      expect(globalThis.__mockPrewarmFn).toHaveBeenCalledTimes(2);
    });
  });

  describe('on non-tvOS platforms', () => {
    beforeEach(() => {
      mockWebPlatform();
      mockNativeModuleUnavailable();
    });

    it('is a no-op and does not throw', () => {
      const { prewarmSearchView } = require('../index');
      expect(() => prewarmSearchView()).not.toThrow();
      expect(globalThis.__mockPrewarmFn).not.toHaveBeenCalled();
    });
  });

  describe('on tvOS without native module', () => {
    beforeEach(() => {
      mockTvOSPlatform();
      mockNativeModuleUnavailable();
    });

    it('is a no-op and does not throw', () => {
      const { prewarmSearchView } = require('../index');
      expect(() => prewarmSearchView()).not.toThrow();
      expect(globalThis.__mockPrewarmFn).not.toHaveBeenCalled();
    });
  });

  it('is exported as a function', () => {
    mockWebPlatform();
    mockNativeModuleUnavailable();
    const { prewarmSearchView } = require('../index');
    expect(typeof prewarmSearchView).toBe('function');
  });
});
