//
//  CharacterData.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

enum EntityKind {
    case tower
    case trap
}

enum GhostMetrics {
    static let diameter: CGFloat = 40
}

struct TowerFoot {
    let center: CGPoint
    let radius: CGFloat

    func overlaps(tile: CGRect) -> Bool {
        let cx = max(tile.minX, min(center.x, tile.maxX))
        let cy = max(tile.minY, min(center.y, tile.maxY))
        let dx = center.x - cx, dy = center.y - cy
        return dx * dx + dy * dy < radius * radius
    }

    func overlaps(_ other: TowerFoot) -> Bool {
        let dx = center.x - other.center.x, dy = center.y - other.center.y
        let r = radius + other.radius
        return dx * dx + dy * dy < r * r
    }
}

enum TowerPlacement {
    static let radius: CGFloat = GhostMetrics.diameter / 2

    static func foot(at feet: CGPoint) -> TowerFoot {
        TowerFoot(center: CGPoint(x: feet.x, y: feet.y + radius), radius: radius)
    }
}

enum TrapPlacement {
    static let pathTolerance: CGFloat = 10
    static let visualRadius: CGFloat = GhostMetrics.diameter / 2
}

struct TowerStats: Hashable {
    let range: CGFloat
    let fireInterval: TimeInterval
    let damage: CGFloat
    let projectileSpeed: CGFloat
    let aoeRadius: CGFloat?

    init(range: CGFloat,
         fireInterval: TimeInterval,
         damage: CGFloat,
         projectileSpeed: CGFloat,
         aoeRadius: CGFloat? = nil) {
        self.range = range
        self.fireInterval = fireInterval
        self.damage = damage
        self.projectileSpeed = projectileSpeed
        self.aoeRadius = aoeRadius
    }
}

struct TrapStats: Hashable {
    let triggerRadius: CGFloat
    let freezeDuration: TimeInterval?
    let runSpeed: CGFloat?
    let slowRadius: CGFloat?
    let slowFactor: CGFloat?
    let slowDuration: TimeInterval?

    init(triggerRadius: CGFloat,
         freezeDuration: TimeInterval? = nil,
         runSpeed: CGFloat? = nil,
         slowRadius: CGFloat? = nil,
         slowFactor: CGFloat? = nil,
         slowDuration: TimeInterval? = nil) {
        self.triggerRadius = triggerRadius
        self.freezeDuration = freezeDuration
        self.runSpeed = runSpeed
        self.slowRadius = slowRadius
        self.slowFactor = slowFactor
        self.slowDuration = slowDuration
    }
}

enum GhostID: String, CaseIterable, Hashable {
    case keti, poci, gugun, yayang, yuyul
}

struct CharacterData: Identifiable, Hashable {
    let id: GhostID
    let name: String
    let cost: Int
    let description: String
    let symbol: String
    let tint: Color
    let kind: EntityKind
    let tower: TowerStats?
    let trap: TrapStats?
    let cooldownDuration: TimeInterval

    var range: CGFloat? { tower?.range }
}

struct GameCollection {
    static func character(for id: GhostID) -> CharacterData {
        guard let c = allCharacters.first(where: { $0.id == id }) else {
            fatalError("No CharacterData for \(id)")
        }
        return c
    }

    static let allCharacters: [CharacterData] = [
      CharacterData(id: .keti, name: "Keti", cost: 6, description: "Keti attacks with piercing sound \nwaves that disable humans.", symbol: "flame.fill", tint: .orange, kind: .tower, tower: TowerStats(range: 100, fireInterval: 2.0, damage: 1, projectileSpeed: 420), trap: nil, cooldownDuration: 4.0),
      CharacterData(id: .poci, name: "Poci", cost: 9, description: "Poci attacks at close range by \ncharging forward and \nheadbutting enemies.", symbol: "drop.fill", tint: .cyan, kind: .tower, tower: TowerStats(range: 60, fireInterval: 0.8, damage: 1, projectileSpeed: 600), trap: nil, cooldownDuration: 8.0),
      CharacterData(id: .gugun, name: "Gugun", cost: 14, description: "Gugun's massive power can wipe \nout up to 5 humans at once.", symbol: "bolt.fill", tint: .yellow, kind: .tower, tower: TowerStats(range: 70, fireInterval: 1.2, damage: 1, projectileSpeed: 500, aoeRadius: 50), trap: nil, cooldownDuration: 14.0),
      CharacterData(id: .yayang, name: "Yayang", cost: 5, description: "Yayang can freeze humans for \n5 seconds by shocking them \nwith its sudden presence.", symbol: "hare.fill", tint: .pink, kind: .trap, tower: nil, trap: TrapStats(triggerRadius: GhostMetrics.diameter / 2 + 6, freezeDuration: 2.0), cooldownDuration: 6.0),
      CharacterData(id: .yuyul, name: "Yuyul", cost: 5, description: "Yuyul creates an area that slows \nhuman movement for 5 seconds.", symbol: "tortoise.fill", tint: .purple, kind: .trap, tower: nil, trap: TrapStats(triggerRadius: GhostMetrics.diameter / 2 + 6, runSpeed: 220, slowRadius: 60, slowFactor: 0.4, slowDuration: 2.0), cooldownDuration: 6.0)
    ]
}
