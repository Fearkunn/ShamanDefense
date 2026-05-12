//
//  EntityRegistry.swift
//  ShamanDefense
//

import GameplayKit

final class EntityRegistry {
    private(set) var humans: Set<GameEntity> = []
    private(set) var towers: Set<GameEntity> = []
    private(set) var traps: Set<GameEntity> = []
    private(set) var projectiles: Set<GameEntity> = []
    private(set) var all: Set<GameEntity> = []

    private let systems: [GKComponentSystem<GKComponent>]

    init(systems: [GKComponentSystem<GKComponent>]) {
        self.systems = systems
    }

    func add(_ entity: GameEntity) {
        guard !all.contains(entity) else { return }
        all.insert(entity)
        switch entity.archetype {
        case .human:      humans.insert(entity)
        case .tower:      towers.insert(entity)
        case .trap:       traps.insert(entity)
        case .projectile: projectiles.insert(entity)
        case .scenery:    break
        }
        for system in systems {
            system.addComponent(foundIn: entity)
        }
    }

    func remove(_ entity: GameEntity) {
        guard all.contains(entity) else { return }
        all.remove(entity)
        humans.remove(entity)
        towers.remove(entity)
        traps.remove(entity)
        projectiles.remove(entity)
        for system in systems {
            system.removeComponent(foundIn: entity)
        }
    }

    func update(deltaTime: TimeInterval) {
        for system in systems {
            system.update(deltaTime: deltaTime)
        }
    }
}
