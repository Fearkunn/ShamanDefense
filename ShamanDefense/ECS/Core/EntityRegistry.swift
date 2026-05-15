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
    private(set) var path: PathComponent?
    private(set) var score: ScoreComponent?
    private(set) var pause: PauseComponent?

    private let systems: [GameSystem]

    init(systems: [GameSystem]) {
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
        case .global:     break
        case .scenery:    break
        }
        if let pc = entity.component(ofType: PathComponent.self) {
            path = pc
        }
        if let psc = entity.component(ofType: PauseComponent.self) {
            pause = psc
        }
        if let sc = entity.component(ofType: ScoreComponent.self) {
            score = sc
        }
        for system in systems {
            system.add(entity)
        }
    }

    func remove(_ entity: GameEntity) {
        guard all.contains(entity) else { return }
        all.remove(entity)
        humans.remove(entity)
        towers.remove(entity)
        traps.remove(entity)
        projectiles.remove(entity)
        if let pc = entity.component(ofType: PathComponent.self), pc === path {
            path = nil
        }
        if let sc = entity.component(ofType: ScoreComponent.self), sc === score {
            score = nil
        }
        for system in systems {
            system.remove(entity)
        }
    }

    func update(deltaTime: TimeInterval) {
        let currentlyPaused = pause?.isPaused ?? false
        for system in systems {
            if currentlyPaused {
                system.update(deltaTime: 0)
            }
            else {
                system.update(deltaTime: deltaTime)
            }
        }
    }
}
