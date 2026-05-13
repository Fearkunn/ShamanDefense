//
//  SpawnerEntity.swift
//  ShamanDefense
//

import GameplayKit

final class SpawnerEntity: GameEntity {
    init(interval: TimeInterval, spawn: @escaping () -> Void) {
        super.init(archetype: .scenery)
        addComponent(SpawnerComponent(interval: interval, spawn: spawn))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
