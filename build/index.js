import React from "react";
import { Platform } from "react-native";
/**
 * Native view component loaded at module initialization.
 * Returns null on non-tvOS platforms or when the native module is unavailable.
 */
let NativeView = null;
if (Platform.OS === "ios" && Platform.isTV) {
    try {
        const { requireNativeViewManager } = require("expo-modules-core");
        if (typeof requireNativeViewManager === "function") {
            NativeView = requireNativeViewManager("ExpoTvosSearch");
        }
    }
    catch {
        // Native module unavailable - TvosSearchView will render null
    }
}
/**
 * Native tvOS search view component using SwiftUI's `.searchable` modifier.
 *
 * This component provides a native search experience on tvOS with proper focus
 * handling and keyboard navigation. On non-tvOS platforms or when the native
 * module is unavailable, it renders `null` - use `isNativeSearchAvailable()`
 * to check availability and render a fallback.
 *
 * @example
 * ```tsx
 * import { TvosSearchView, isNativeSearchAvailable } from 'expo-tvos-search';
 *
 * function SearchScreen() {
 *   const [results, setResults] = useState<SearchResult[]>([]);
 *
 *   if (!isNativeSearchAvailable()) {
 *     return <FallbackSearchComponent />;
 *   }
 *
 *   return (
 *     <TvosSearchView
 *       results={results}
 *       onSearch={(e) => fetchResults(e.nativeEvent.query)}
 *       onSelectItem={(e) => router.push(`/detail/${e.nativeEvent.id}`)}
 *       style={{ flex: 1 }}
 *     />
 *   );
 * }
 * ```
 *
 * @param props - Component props
 * @returns The native search view on tvOS, or `null` if unavailable
 */
export function TvosSearchView(props) {
    if (!NativeView) {
        return null;
    }
    return React.createElement(NativeView, { ...props });
}
/**
 * Checks if the native tvOS search component is available.
 *
 * Returns `true` only when:
 * - Running on tvOS (Platform.OS === "ios" && Platform.isTV)
 * - The native module has been built (via `expo prebuild`)
 * - expo-modules-core is properly installed
 *
 * Use this to conditionally render a fallback search implementation
 * on non-tvOS platforms or when the native module is unavailable.
 *
 * @returns `true` if TvosSearchView will render, `false` if it will return null
 *
 * @example
 * ```tsx
 * if (!isNativeSearchAvailable()) {
 *   return <ReactNativeSearchFallback />;
 * }
 * return <TvosSearchView {...props} />;
 * ```
 */
export function isNativeSearchAvailable() {
    return NativeView !== null;
}
