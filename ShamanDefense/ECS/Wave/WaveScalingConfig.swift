//
//  WaveScalingConfig.swift
//  ShamanDefense
//

import Foundation
import CoreGraphics

struct WaveScalingConfig {
    var baseCount: Int = 8
    var countPerWave: Int = 5

    var jitterFraction: Double = 0.25
    var maxGroupStartOffset: TimeInterval = 2.5

    var intermission: TimeInterval = 5.0
    var firstIntermission: TimeInterval = 3.0

    static let `default` = WaveScalingConfig()

    func count(for wave: Int) -> Int {
        max(1, baseCount + countPerWave * (wave - 1))
    }

    func globalHpMultiplier(for wave: Int) -> CGFloat {
        let bonus = max(0, CGFloat(wave - 5)) * 0.06
        return 1.0 + bonus
    }

    func archetypeWeights(for wave: Int) -> [(HumanArchetype, Double)] {
        var weights: [(HumanArchetype, Double)] = []
        for arch in HumanArchetype.allCases where wave >= arch.unlockWave {
            let w = baseWeight(for: arch.tier, wave: wave) * (arch.isFast ? 0.5 : 1.0)
            if w > 0 { weights.append((arch, w)) }
        }
        return weights
    }

    private func baseWeight(for tier: HumanArchetype.Tier, wave: Int) -> Double {
        switch tier {
        case .blue:
            return max(0.2, 5.0 - Double(wave) * 0.8)
        case .green:
            let rise = min(4.5, Double(wave - 2) * 0.8)
            let decay = max(0.0, Double(wave - 7) * 0.6)
            return max(0.2, rise - decay)
        case .yellow:
            let rise = min(5.0, Double(wave - 4) * 0.9)
            let decay = max(0.0, Double(wave - 10) * 0.5)
            return max(0.3, rise - decay)
        case .orange:
            return min(6.0, Double(wave - 6) * 0.9)
        case .red:
            return min(6.0, Double(wave - 9) * 1.0)
        }
    }
}
