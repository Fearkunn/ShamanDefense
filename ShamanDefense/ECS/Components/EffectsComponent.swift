//
//  EffectsComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class EffectsComponent: GKComponent {
    private var slowRemaining: TimeInterval = 0
    private var slowFactor: CGFloat = 1
    private var freezeRemaining: TimeInterval = 0

    var isFrozen: Bool { freezeRemaining > 0 }
    var isSlowed: Bool { slowRemaining > 0 }
    var currentSpeedFactor: CGFloat { isSlowed ? slowFactor : 1 }

    func applySlow(factor: CGFloat, duration: TimeInterval) {
        slowFactor = factor
        slowRemaining = max(slowRemaining, duration)
    }

    func applyFreeze(duration: TimeInterval) {
        freezeRemaining = max(freezeRemaining, duration)
    }

    override func update(deltaTime seconds: TimeInterval) {
        if slowRemaining > 0 {
            slowRemaining = max(0, slowRemaining - seconds)
        }
        if freezeRemaining > 0 {
            freezeRemaining = max(0, freezeRemaining - seconds)
        }
        if let pf = entity?.component(ofType: PathFollowComponent.self) {
            pf.speedMultiplier = currentSpeedFactor
            pf.frozen = isFrozen
        }
    }
}
