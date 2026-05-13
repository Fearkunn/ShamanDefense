//
//  EffectsComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class EffectsComponent: GKComponent {
    var slowRemaining: TimeInterval = 0
    var slowFactor: CGFloat = 1
    var freezeRemaining: TimeInterval = 0

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
}
