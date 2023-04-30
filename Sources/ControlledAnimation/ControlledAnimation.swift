//
//  ControlledAnimation.swift
//  
//
//  Created by Luke Zhao on 4/30/23.
//

import UIKit

extension UIView {
    /// Animation configuration for specific action and event type on a view
    /// ```
    /// // To setup the animation configuration
    /// view.controlledAnimations = [
    ///     "buttonAnimation": [
    ///         "opacity": .easeInOut(duration: 0.3)
    ///         "bounds": .spring(stiffness: 300, damping: 20)
    ///         "position": .spring(stiffness: 300, damping: 20)
    ///     ]
    /// ]
    ///
    /// // To run the animation
    /// UIView.animate("buttonAnimation") {
    ///     updateView() // trigger update to opacity, bounds, and position
    /// }
    /// ```
    public var controlledAnimations: [String: [String: AnimationConfig]]? {
        get { objc_getAssociatedObject(self, &type(of: self).AssociatedKeys.controlledAnimations) as? [String: [String: AnimationConfig]] ?? [:] }
        set { objc_setAssociatedObject(self, &type(of: self).AssociatedKeys.controlledAnimations, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Start the animation of certain controlled animation actions
    /// - Parameters:
    ///   - actions: name of animation actions to run
    ///   - animations: update block to trigger the view value updates
    ///   - completion: completion block to be called when the animation is finished
    public class func animate(_ actions: String..., animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        animate(actions, animations: animations, completion: completion)
    }

    /// Start the animation of certain controlled animation actions
    /// - Parameters:
    ///   - actions: array of name of animation actions to run
    ///   - animations: update block to trigger the view value updates
    ///   - completion: completion block to be called when the animation is finished
    public class func animate(_ actions: [String], animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        let insertedActions = actions.filter { !animatingActions.contains($0) }
        for action in insertedActions {
            animatingActions.insert(action)
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        // animate
        animations()

        CATransaction.commit()

        for action in insertedActions {
            animatingActions.remove(action)
        }
    }
}

// MARK: - Private

extension UIView {
    fileprivate struct AssociatedKeys {
        static var controlledAnimations = "controlledAnimations"
    }

    fileprivate static let swizzleActionMethods: Void = {
        let originalMethod = class_getInstanceMethod(UIView.self, #selector(UIView.action(for:forKey:)))!
        let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(UIView.swizzled_action(for:forKey:)))!
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    fileprivate static var animatingActions: Set<String> = [] {
        didSet {
            assert(Thread.isMainThread)
            _ = UIScrollView.swizzleActionMethods
        }
    }

    @objc fileprivate func swizzled_action(for layer: CALayer, forKey event: String) -> CAAction? {
        guard !Self.animatingActions.isEmpty, let controlledAnimations else {
            return swizzled_action(for: layer, forKey: event)
        }
        for action in Self.animatingActions {
            if let config = controlledAnimations[action]?[event] {
                let anim = config.generateAnimation()
                anim.fillMode = .both
                anim.isRemovedOnCompletion = true
                anim.keyPath = event
                return anim
            } else {
                print("No controlled actions for view: \(self), action: \(action), event: \(event)")
            }
        }
        return NSNull()
    }
}
