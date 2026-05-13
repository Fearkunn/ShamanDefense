//
//  SpawnerSystem.swift
//  ShamanDefense
//

import GameplayKit

final class SpawnerSystem: ComponentSystem<SpawnerComponent> {
    override func update(deltaTime: TimeInterval) {
        for spawner in components {
            spawner.accum += deltaTime
            while spawner.accum >= spawner.interval {
                spawner.accum -= spawner.interval
                spawner.spawn()
            }
        }
    }
}
