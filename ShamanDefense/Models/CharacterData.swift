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
}

struct GameCollection {
    static let allCharacters: [CharacterData] = [
        CharacterData(id: .keti,   name: "Keti",   cost: 3, symbol: "flame.fill",    tint: .orange, kind: .tower),
        CharacterData(id: .poci,   name: "Poci",   cost: 4, symbol: "drop.fill",     tint: .cyan,   kind: .tower),
        CharacterData(id: .gugun,  name: "Gugun",  cost: 5, symbol: "bolt.fill",     tint: .yellow, kind: .tower),
        CharacterData(id: .yayang, name: "Yayang", cost: 2, symbol: "hare.fill",     tint: .pink,   kind: .trap),
        CharacterData(id: .yuyul,  name: "Yuyul",  cost: 2, symbol: "tortoise.fill", tint: .purple, kind: .trap)
    ]
}
