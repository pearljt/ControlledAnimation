//
//  AnimationConfig.swift
//  
//
//  Created by Luke Zhao on 4/30/23.
//

import UIKit

public struct AnimationConfig {
    public let generator: AnimationGenerator
    public init(generator: AnimationGenerator) {
        self.generator = generator
    }
    public func generateAnimation() -> CAPropertyAnimation {
        generator.generateAnimation()
    }
}

public extension AnimationConfig {
    static func spring(stiffness: CGFloat, damping: CGFloat) -> AnimationConfig {
        AnimationConfig(generator: SpringAnimationGenerator(stiffness: stiffness, damping: damping))
    }
    static func easeInOut(duration: TimeInterval) -> AnimationConfig {
        AnimationConfig(generator: CurveAnimationGenerator(timingFunctionName: .easeInEaseOut, duration: duration))
    }
    static func easeIn(duration: TimeInterval) -> AnimationConfig {
        AnimationConfig(generator: CurveAnimationGenerator(timingFunctionName: .easeIn, duration: duration))
    }
    static func easeOut(duration: TimeInterval) -> AnimationConfig {
        AnimationConfig(generator: CurveAnimationGenerator(timingFunctionName: .easeOut, duration: duration))
    }
    static func linear(duration: TimeInterval) -> AnimationConfig {
        AnimationConfig(generator: CurveAnimationGenerator(timingFunctionName: .linear, duration: duration))
    }
}

public protocol AnimationGenerator {
    func generateAnimation() -> CAPropertyAnimation
}

public struct SpringAnimationGenerator: AnimationGenerator {
    public let stiffness: CGFloat
    public let damping: CGFloat

    public init(stiffness: CGFloat, damping: CGFloat) {
        self.stiffness = stiffness
        self.damping = damping
    }

    public func generateAnimation() -> CAPropertyAnimation {
        let anim = CASpringAnimation()
        anim.stiffness = stiffness
        anim.damping = damping
        anim.duration = anim.settlingDuration
        return anim
    }
}

public struct CurveAnimationGenerator: AnimationGenerator {
    public let timingFunction: CAMediaTimingFunction
    public let duration: TimeInterval

    public init(timingFunction: CAMediaTimingFunction, duration: TimeInterval) {
        self.timingFunction = timingFunction
        self.duration = duration
    }

    public init(timingFunctionName: CAMediaTimingFunctionName, duration: TimeInterval) {
        self.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        self.duration = duration
    }

    public func generateAnimation() -> CAPropertyAnimation {
        let anim = CABasicAnimation()
        anim.timingFunction = timingFunction
        anim.duration = duration
        return anim
    }
}
