import XCTest

/// Test helper that simulates the gesture handler reference counting behavior
/// This mirrors the implementation in ExpoTvosSearchView for isolated testing
class GestureHandlerReferenceCounter {
    static var disabledInstanceCount = 0
    
    /// Tracks disable notification posts for testing
    static var disableNotificationPostCount = 0
    /// Tracks enable notification posts for testing
    static var enableNotificationPostCount = 0
    
    private var isDisabled = false
    
    /// Resets all static counters for clean test state
    static func reset() {
        disabledInstanceCount = 0
        disableNotificationPostCount = 0
        enableNotificationPostCount = 0
    }
    
    /// Simulates disabling gesture handlers for this instance
    func disableGestureHandlers() {
        guard !isDisabled else { return }
        
        isDisabled = true
        Self.disabledInstanceCount += 1
        
        if Self.disabledInstanceCount == 1 {
            // Would post RCTTVDisableGestureHandlersCancelTouches notification
            Self.disableNotificationPostCount += 1
        }
    }
    
    /// Simulates enabling gesture handlers for this instance
    func enableGestureHandlers() {
        guard isDisabled else { return }
        
        isDisabled = false
        Self.disabledInstanceCount -= 1
        
        if Self.disabledInstanceCount == 0 {
            // Would post RCTTVEnableGestureHandlersCancelTouches notification
            Self.enableNotificationPostCount += 1
        }
    }
    
    /// Simulates deinit cleanup when instance has handlers disabled
    func simulateDeinit() {
        if isDisabled {
            Self.disabledInstanceCount -= 1
            if Self.disabledInstanceCount == 0 {
                Self.enableNotificationPostCount += 1
            }
        }
    }
    
    /// Whether this instance currently has gesture handlers disabled
    var gestureHandlersDisabled: Bool {
        return isDisabled
    }
}

/// Unit tests for gesture handler reference counting logic
/// These tests verify that multi-instance gesture handler cleanup works correctly
final class GestureHandlerReferenceCountingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        GestureHandlerReferenceCounter.reset()
    }
    
    override func tearDown() {
        GestureHandlerReferenceCounter.reset()
        super.tearDown()
    }
    
    // MARK: - Single Instance Tests
    
    func testSingleInstance_disablePostsNotification() {
        let instance = GestureHandlerReferenceCounter()
        
        instance.disableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1, 
                       "Should post disable notification once")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Clean up
        instance.enableGestureHandlers()
    }
    
    func testSingleInstance_enablePostsNotification() {
        let instance = GestureHandlerReferenceCounter()
        
        instance.disableGestureHandlers()
        instance.enableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1, 
                       "Should post enable notification once")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    func testSingleInstance_doubleDisableOnlyPostsOnce() {
        let instance = GestureHandlerReferenceCounter()
        
        instance.disableGestureHandlers()
        instance.disableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1, 
                       "Should only post disable notification once for double disable")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Clean up
        instance.enableGestureHandlers()
    }
    
    func testSingleInstance_enableWithoutDisableDoesNothing() {
        let instance = GestureHandlerReferenceCounter()
        
        instance.enableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0, 
                       "Should not post enable notification when not disabled")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    func testSingleInstance_gestureHandlersDisabledTracking() {
        let instance = GestureHandlerReferenceCounter()
        
        XCTAssertFalse(instance.gestureHandlersDisabled)
        
        instance.disableGestureHandlers()
        XCTAssertTrue(instance.gestureHandlersDisabled)
        
        instance.enableGestureHandlers()
        XCTAssertFalse(instance.gestureHandlersDisabled)
    }
    
    // MARK: - Multi-Instance Tests
    
    func testMultiInstance_secondDisableDoesNotPostNotification() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1, 
                       "Should only post disable notification once for multiple instances")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 2)
        
        // Clean up
        instance1.enableGestureHandlers()
        instance2.enableGestureHandlers()
    }
    
    func testMultiInstance_firstEnableDoesNotPostNotification() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        
        instance1.enableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0, 
                       "Should not post enable when other instances still have handlers disabled")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Clean up
        instance2.enableGestureHandlers()
    }
    
    func testMultiInstance_lastEnablePostsNotification() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        
        instance1.enableGestureHandlers()
        instance2.enableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1, 
                       "Should post enable notification when last instance re-enables")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    func testMultiInstance_threeInstances_correctReferenceCount() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        let instance3 = GestureHandlerReferenceCounter()
        
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        instance3.disableGestureHandlers()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1, 
                       "Should only post disable notification once")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 3)
        
        // Enable first two - should not post
        instance1.enableGestureHandlers()
        instance2.enableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0, 
                       "Should not post enable until last instance")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Enable last one - should post
        instance3.enableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1, 
                       "Should post enable when last instance re-enables")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    // MARK: - Deinit Behavior Tests
    
    func testDeinit_singleInstance_postsEnableNotification() {
        let instance = GestureHandlerReferenceCounter()
        instance.disableGestureHandlers()
        
        instance.simulateDeinit()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1, 
                       "Deinit should post enable notification for single disabled instance")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    func testDeinit_multipleInstances_onlyLastPostsNotification() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        
        // First deinit - should not post
        instance1.simulateDeinit()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0, 
                       "First deinit should not post enable notification")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Second deinit - should post
        instance2.simulateDeinit()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1, 
                       "Last deinit should post enable notification")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    func testDeinit_notDisabled_doesNothing() {
        let instance = GestureHandlerReferenceCounter()
        
        instance.simulateDeinit()
        
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0, 
                       "Deinit should not post if handlers were not disabled")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
    }
    
    // MARK: - Edge Case Tests
    
    func testMixedDisableEnable_correctCount() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        // Disable both
        instance1.disableGestureHandlers()
        instance2.disableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1)
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 2)
        
        // Enable first, should not post enable
        instance1.enableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 0)
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Reset notification count for clarity
        GestureHandlerReferenceCounter.disableNotificationPostCount = 0
        
        // Disable first again, should not post disable (already one disabled)
        instance1.disableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 0, 
                       "Should not post disable again when another instance already has handlers disabled")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 2)
        
        // Clean up
        instance1.enableGestureHandlers()
        instance2.enableGestureHandlers()
    }
    
    func testInterleavedDisableEnable_correctBehavior() {
        let instance1 = GestureHandlerReferenceCounter()
        let instance2 = GestureHandlerReferenceCounter()
        
        // Disable instance1
        instance1.disableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 1)
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Enable instance1
        instance1.enableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.enableNotificationPostCount, 1)
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 0)
        
        // Disable instance2 - should post again
        instance2.disableGestureHandlers()
        XCTAssertEqual(GestureHandlerReferenceCounter.disableNotificationPostCount, 2, 
                       "Should post disable again after all were enabled")
        XCTAssertEqual(GestureHandlerReferenceCounter.disabledInstanceCount, 1)
        
        // Clean up
        instance2.enableGestureHandlers()
    }
}
