//
//  GameSystem.swift
//  ShamanDefense
//

import GameplayKit

protocol GameSystem: AnyObject {
    func add(_ entity: GameEntity)
    func remove(_ entity: GameEntity)
    func update(deltaTime: TimeInterval)
}

class ComponentSystem<T: GKComponent>: GameSystem {
    let inner = GKComponentSystem(componentClass: T.self)

    var components: [T] { inner.components as? [T] ?? [] }

    func add(_ entity: GameEntity) {
        inner.addComponent(foundIn: entity)
    }

    func remove(_ entity: GameEntity) {
        inner.removeComponent(foundIn: entity)
    }

    func update(deltaTime: TimeInterval) {}
}
