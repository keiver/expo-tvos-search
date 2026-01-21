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
        else {
            console.warn("[expo-tvos-search] requireNativeViewManager is not a function. " +
                "This usually indicates an incompatible expo-modules-core version. " +
                "Try reinstalling expo-modules-core or updating to a compatible version.");
        }
    }
    catch (error) {
        // Categorize the error to help with debugging
        const errorMessage = error instanceof Error ? error.message : String(error);
        if (errorMessage.includes("expo-modules-core")) {
            console.warn("[expo-tvos-search] Failed to load expo-modules-core. " +
                "Make sure expo-modules-core is installed: npm install expo-modules-core\n" +
                `Error: ${errorMessage}`);
        }
        else if (errorMessage.includes("ExpoTvosSearch")) {
            console.warn("[expo-tvos-search] Native module ExpoTvosSearch not found. " +
                "This usually means:\n" +
                "1. You haven't run 'expo prebuild' yet, or\n" +
                "2. The native project needs to be rebuilt (try 'expo prebuild --clean')\n" +
                "3. You're not running on a tvOS simulator/device\n" +
                `Error: ${errorMessage}`);
        }
        else {
            // Unexpected error - log full details for debugging
            console.warn("[expo-tvos-search] Unexpected error loading native module.\n" +
                `Error: ${errorMessage}\n` +
                "Please report this issue at: https://github.com/keiver/expo-tvos-search/issues");
            // In development, log the full error for debugging
            if (typeof __DEV__ !== "undefined" && __DEV__) {
                console.error("[expo-tvos-search] Full error details:", error);
            }
        }
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
        // Warn in development when native module is unavailable
        if (typeof __DEV__ !== "undefined" && __DEV__) {
            const isRunningOnTvOS = Platform.OS === "ios" && Platform.isTV;
            if (isRunningOnTvOS) {
                // On tvOS but module failed to load - this is unexpected
                console.warn("[expo-tvos-search] TvosSearchView is rendering null on tvOS. " +
                    "This usually means:\n" +
                    "1. The native module wasn't built properly (try 'expo prebuild --clean')\n" +
                    "2. expo-modules-core is missing or incompatible\n" +
                    "3. The app needs to be restarted after installing the module\n\n" +
                    "Check the earlier console logs for specific error details.");
            }
            else {
                // Not on tvOS - expected behavior, but developer might want to know
                console.info("[expo-tvos-search] TvosSearchView is not available on " +
                    `${Platform.OS}${Platform.isTV ? " (TV)" : ""}. ` +
                    "Use isNativeSearchAvailable() to check before rendering this component.");
            }
        }
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
