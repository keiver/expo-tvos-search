import XCTest
@testable import ExpoTvosSearchCore

#if os(tvOS)

/// Unit tests for the container that hosts React children in the results region.
@MainActor
final class ChildrenHostTests: XCTestCase {

    // MARK: - Recycling

    /// The regression this container exists for. Fabric pools view instances
    /// (RCTComponentViewRegistry `_recyclePool`) and asserts a pooled view has no superview, so an
    /// unmount detaches and the very next mount can hand back the same instance. An implementation
    /// that skips re-attachment when the set of views looks unchanged leaves it detached and the
    /// region renders blank.
    func testAttach_afterDetach_reattachesTheSameInstance() {
        let container = ChildrenContainerView()
        let recycled = UIView()

        container.attach(recycled, at: 0)
        container.detach(recycled)
        container.attach(recycled, at: 0)

        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertTrue(recycled.superview === container)
    }

    func testAttach_twiceWithoutDetach_doesNotDuplicate() {
        let container = ChildrenContainerView()
        let view = UIView()

        container.attach(view, at: 0)
        container.attach(view, at: 0)

        XCTAssertEqual(container.subviews.count, 1)
    }

    // MARK: - Ordering

    func testAttach_keepsMountOrder() {
        let container = ChildrenContainerView()
        let views = [UIView(), UIView(), UIView()]

        for (index, view) in views.enumerated() {
            container.attach(view, at: index)
        }

        XCTAssertEqual(container.subviews.count, 3)
        XCTAssertTrue(container.subviews[0] === views[0])
        XCTAssertTrue(container.subviews[1] === views[1])
        XCTAssertTrue(container.subviews[2] === views[2])
    }

    func testAttach_insertsAtTheGivenIndex() {
        let container = ChildrenContainerView()
        let first = UIView(), last = UIView(), middle = UIView()

        container.attach(first, at: 0)
        container.attach(last, at: 1)
        container.attach(middle, at: 1)

        XCTAssertTrue(container.subviews[0] === first)
        XCTAssertTrue(container.subviews[1] === middle)
        XCTAssertTrue(container.subviews[2] === last)
    }

    func testAttach_clampsAnOutOfRangeIndex() {
        let container = ChildrenContainerView()
        let view = UIView()

        container.attach(view, at: 99)

        XCTAssertEqual(container.subviews.count, 1)
    }

    // MARK: - Detaching

    func testDetach_removesOnlyTheNamedView() {
        let container = ChildrenContainerView()
        let keep = UIView(), drop = UIView()
        container.attach(keep, at: 0)
        container.attach(drop, at: 1)

        container.detach(drop)

        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertTrue(container.subviews[0] === keep)
        XCTAssertNil(drop.superview)
    }

    func testDetach_leavesAViewOwnedByAnotherParentAlone() {
        let container = ChildrenContainerView()
        let other = UIView()
        let view = UIView()
        other.addSubview(view)

        container.detach(view)

        XCTAssertTrue(view.superview === other)
    }

    // MARK: - Recycling the host

    func testReset_dropsEveryChild() {
        let container = ChildrenContainerView()
        let views = [UIView(), UIView()]
        views.enumerated().forEach { container.attach($1, at: $0) }

        container.reset()

        XCTAssertTrue(container.subviews.isEmpty)
        XCTAssertNil(views[0].superview)
        XCTAssertNil(views[1].superview)
    }

    func testReset_thenAttachStartsClean() {
        let container = ChildrenContainerView()
        let stale = UIView(), fresh = UIView()
        container.attach(stale, at: 0)

        container.reset()
        container.attach(fresh, at: 0)

        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertTrue(container.subviews[0] === fresh)
    }

    // MARK: - Layout

    func testLayout_childrenFillBounds() {
        let container = ChildrenContainerView()
        let views = [UIView(), UIView()]
        views.enumerated().forEach { container.attach($1, at: $0) }

        container.frame = CGRect(x: 0, y: 0, width: 1760, height: 617)
        container.layoutIfNeeded()

        XCTAssertEqual(views[0].frame, container.bounds)
        XCTAssertEqual(views[1].frame, container.bounds)
    }

    // MARK: - Size reporting

    func testSizeChange_reportsTheRegionOnce() {
        let container = ChildrenContainerView()
        var reported: [CGSize] = []
        container.onSizeChange = { reported.append($0) }
        container.attach(UIView(), at: 0)

        container.frame = CGRect(x: 0, y: 0, width: 1760, height: 617)
        container.layoutIfNeeded()
        container.setNeedsLayout()
        container.layoutIfNeeded()

        XCTAssertEqual(reported, [CGSize(width: 1760, height: 617)])
    }

    func testSizeChange_reportsAgainWhenTheRegionChanges() {
        let container = ChildrenContainerView()
        var reported: [CGSize] = []
        container.onSizeChange = { reported.append($0) }

        container.frame = CGRect(x: 0, y: 0, width: 1760, height: 617)
        container.layoutIfNeeded()
        container.frame = CGRect(x: 0, y: 0, width: 1760, height: 400)
        container.layoutIfNeeded()

        XCTAssertEqual(reported, [CGSize(width: 1760, height: 617), CGSize(width: 1760, height: 400)])
    }

    func testSizeChange_staysQuietAtZeroBounds() {
        let container = ChildrenContainerView()
        var reported: [CGSize] = []
        container.onSizeChange = { reported.append($0) }

        container.frame = .zero
        container.layoutIfNeeded()

        XCTAssertTrue(reported.isEmpty)
    }

    func testLayout_zeroBoundsLeavesFramesAlone() {
        let container = ChildrenContainerView()
        let view = UIView(frame: CGRect(x: 1, y: 2, width: 3, height: 4))
        container.attach(view, at: 0)

        container.frame = .zero
        container.layoutIfNeeded()

        XCTAssertEqual(view.frame, CGRect(x: 1, y: 2, width: 3, height: 4))
    }
}

#endif
