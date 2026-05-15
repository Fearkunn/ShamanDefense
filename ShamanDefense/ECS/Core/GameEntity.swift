//
//  GameEntity.swift
//  ShamanDefense
//

import GameplayKit

enum EntityArchetype {
    case human
    case tower
    case trap
    case projectile
    case scenery
    case global
}

class GameEntity: GKEntity {
    let archetype: EntityArchetype

    init(archetype: EntityArchetype) {
        self.archetype = archetype
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func require<C: GKComponent>(_ type: C.Type) -> C {
        guard let c = component(ofType: type) else {
            fatalError("\(self) missing required component \(type)")
        }
        return c
    }
}
