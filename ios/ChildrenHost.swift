#if os(tvOS)

import SwiftUI

/// Hosts the React children in the results region.
///
/// SwiftUI mutates the view it is handed (frame, autoresizingMask, visibility), sometimes after
/// teardown, which corrupts a recycled React view. So SwiftUI only ever sees this container and
/// the React views stay its subviews (the mitigation expo-modules-core uses in `UIViewHost`).
///
/// The container outlives every mount, so a view Fabric hands back from its recycle pool
/// re-attaches here without SwiftUI having to observe anything.
final class ChildrenContainerView: UIView {
    /// Reports the region's size so the consumer can lay its subtree out against the box it is
    /// actually drawn in. React sizes the child against the whole native view, which is larger.
    var onSizeChange: ((CGSize) -> Void)?

    private var reportedSize: CGSize = .zero

    /// Attaches a React child at `index`, clamped to the current count. Safe with a view that was
    /// attached before: Fabric reuses instances, and `insertSubview` moves rather than duplicates.
    func attach(_ view: UIView, at index: Int) {
        let position = min(max(0, index), subviews.count)
        insertSubview(view, at: position)
        setNeedsLayout()
    }

    /// Drops every child. Fabric pools the hosting view too, so a reused one must not come back
    /// carrying the previous mount's children.
    func reset() {
        subviews.forEach { $0.removeFromSuperview() }
        setNeedsLayout()
    }

    /// Fabric asserts a view has no superview before it can go back in the recycle pool.
    func detach(_ view: UIView) {
        guard view.superview === self else { return }
        view.removeFromSuperview()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !bounds.isEmpty else { return }
        for child in subviews where child.frame != bounds {
            child.frame = bounds
        }
        if bounds.size != reportedSize {
            reportedSize = bounds.size
            onSizeChange?(bounds.size)
        }
    }
}

struct ChildrenHost: UIViewRepresentable {
    let container: ChildrenContainerView

    func makeUIView(context: Context) -> ChildrenContainerView {
        container
    }

    func updateUIView(_ uiView: ChildrenContainerView, context: Context) {
        // Attachment is the native view's job, not SwiftUI's.
    }
}

#endif
