//
//  TowerStates.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class TowerIdleState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == TowerAcquiringState.self
    }
    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(TowerAcquiringState.self)
    }
}

final class TowerAcquiringState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == TowerFiringState.self
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let entity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let targeting = entity.component(ofType: TargetingComponent.self),
              let scene = sprite.node.scene as? GameScene else { return }

        if targeting.acquire(from: sprite.position, in: scene.registry) != nil {
            stateMachine?.enter(TowerFiringState.self)
        }
    }
}

final class TowerFiringState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == TowerCooldownState.self
    }

    override func didEnter(from previousState: GKState?) {
        guard let entity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let targeting = entity.component(ofType: TargetingComponent.self),
              let launcher = entity.component(ofType: ProjectileLauncherComponent.self),
              let firing = entity.component(ofType: FiringComponent.self),
              let target = targeting.currentTarget,
              let scene = sprite.node.scene as? GameScene else {
            stateMachine?.enter(TowerCooldownState.self)
            return
        }

        if let dir = entity.component(ofType: DirectionalSpriteComponent.self),
           let targetPos = target.component(ofType: SpriteComponent.self)?.position {
            dir.face(dx: targetPos.x - sprite.position.x,
                     dy: targetPos.y - sprite.position.y)
        }

        scene.spawnProjectile(from: sprite.position, target: target, launcher: launcher)
        firing.resetCooldown()
        stateMachine?.enter(TowerCooldownState.self)
    }
}

final class TowerCooldownState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == TowerAcquiringState.self
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let firing = entity?.component(ofType: FiringComponent.self) else { return }
        firing.tickCooldown(seconds)
        if firing.ready {
            stateMachine?.enter(TowerAcquiringState.self)
        }
    }
}
