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
    static let diameter: CGFloat = 30
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
    let symbol: String
    let tint: Color
    let kind: EntityKind
    let tower: TowerStats?
    let trap: TrapStats?

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
        CharacterData(id: .keti,   name: "Keti",   cost: 3, symbol: "flame.fill",    tint: .orange, kind: .tower,
                      tower: TowerStats(range: 100, fireInterval: 2.0, damage: 1, projectileSpeed: 420),
                      trap: nil),
        CharacterData(id: .poci,   name: "Poci",   cost: 4, symbol: "drop.fill",     tint: .cyan,   kind: .tower,
                      tower: TowerStats(range: 60,  fireInterval: 0.8, damage: 1, projectileSpeed: 600),
                      trap: nil),
        CharacterData(id: .gugun,  name: "Gugun",  cost: 5, symbol: "bolt.fill",     tint: .yellow, kind: .tower,
                      tower: TowerStats(range: 70, fireInterval: 1.2, damage: 1, projectileSpeed: 500, aoeRadius: 50),
                      trap: nil),
        CharacterData(id: .yayang, name: "Yayang", cost: 2, symbol: "hare.fill",     tint: .pink,   kind: .trap,
                      tower: nil,
                      trap: TrapStats(triggerRadius: GhostMetrics.diameter / 2 + 6, freezeDuration: 2.0)),
        CharacterData(id: .yuyul,  name: "Yuyul",  cost: 2, symbol: "tortoise.fill", tint: .purple, kind: .trap,
                      tower: nil,
                      trap: TrapStats(triggerRadius: GhostMetrics.diameter / 2 + 6,
                                      runSpeed: 220, slowRadius: 60, slowFactor: 0.4, slowDuration: 2.0))
    ]
}
