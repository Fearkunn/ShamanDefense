//
//  HumanArchetype.swift
//  ShamanDefense
//

import Foundation
import CoreGraphics

enum HumanArchetype: CaseIterable {
    case blue
    case green
    case yellow
    case orange
    case red
    case blueFast
    case greenFast
    case yellowFast
    case orangeFast
    case redFast

    var tier: Tier {
        switch self {
        case .blue, .blueFast:     return .blue
        case .green, .greenFast:   return .green
        case .yellow, .yellowFast: return .yellow
        case .orange, .orangeFast: return .orange
        case .red, .redFast:       return .red
        }
    }

    var isFast: Bool {
        switch self {
        case .blueFast, .greenFast, .yellowFast, .orangeFast, .redFast: return true
        default: return false
        }
    }

    var hpMultiplier: CGFloat { tier.hp }
    var speedMultiplier: CGFloat { isFast ? 1.8 : 1.0 }

    var unlockWave: Int {
        switch self {
        case .blue:        return 1
        case .blueFast:    return 3
        case .green:       return 3
        case .greenFast:   return 4
        case .yellow:      return 5
        case .yellowFast:  return 6
        case .orange:      return 7
        case .orangeFast:  return 8
        case .red:         return 10
        case .redFast:     return 11
        }
    }

    var baseSpawnGap: TimeInterval {
        let tierGap: TimeInterval = tier.baseGap
        return isFast ? tierGap * 0.4 : tierGap
    }

    var spriteSuffix: String? { tier.spriteSuffix }

    enum Tier {
        case blue, green, yellow, orange, red

        var hp: CGFloat {
            switch self {
            case .blue:   return 1
            case .green:  return 2
            case .yellow: return 4
            case .orange: return 8
            case .red:    return 16
            }
        }

        var baseGap: TimeInterval {
            switch self {
            case .blue:   return 1.0
            case .green:  return 1.0
            case .yellow: return 1.2
            case .orange: return 1.5
            case .red:    return 1.8
            }
        }

        var spriteSuffix: String? {
            switch self {
            case .blue:   return nil
            case .green:  return "green"
            case .yellow: return "yellow"
            case .orange: return "orange"
            case .red:    return "red"
            }
        }
    }
}
