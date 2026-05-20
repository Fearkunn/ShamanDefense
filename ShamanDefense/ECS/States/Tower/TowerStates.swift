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

        if launcher.sourceGhostID != .poci,
           let dir = entity.component(ofType: DirectionalSpriteComponent.self),
           let targetPos = target.component(ofType: SpriteComponent.self)?.position {
            dir.face(dx: targetPos.x - sprite.position.x,
                     dy: targetPos.y - sprite.position.y)
        }

        if launcher.sourceGhostID == .poci,
           let body = sprite.node.children.first(where: { $0 is SKSpriteNode }) as? SKSpriteNode {
            let originalTexture = body.texture
            let originalSize = body.size
            let originalXScale = body.xScale
            let originalYScale = body.yScale

            let headbuttTexture = SKTexture(imageNamed: "poci_headbutt")
            body.texture = headbuttTexture
            body.size = CharacterSprites.size(for: headbuttTexture, height: CharacterSprites.spriteHeight)
            let facingX: CGFloat
            if let targetPos = target.component(ofType: SpriteComponent.self)?.position {
                // Face toward the lane target during headbutt.
                facingX = targetPos.x >= sprite.position.x ? -abs(originalXScale) : abs(originalXScale)
            } else if let path = scene.registry.path, path.waypoints.count >= 2 {
                // Fallback: face lane flow direction of the nearest segment.
                let i = path.nearestSegmentIndex(to: sprite.position)
                let a = path.waypoints[i]
                let b = path.waypoints[min(i + 1, path.waypoints.count - 1)]
                facingX = (b.x - a.x) >= 0 ? -abs(originalXScale) : abs(originalXScale)
            } else {
                facingX = originalXScale
            }
            body.xScale = facingX
            body.run(
                .sequence([
                    .group([
                        .scaleX(to: facingX * 1.12, y: originalYScale * 1.12, duration: 0.07),
                        .moveBy(x: 0, y: 4, duration: 0.12)
                    ]),
                    .group([
                        .scaleX(to: facingX, y: originalYScale, duration: 0.07),
                        .moveBy(x: 0, y: -4, duration: 0.12)
                    ]),
                    .run {
                        body.texture = originalTexture
                        body.size = originalSize
                        body.xScale = originalXScale
                        body.yScale = originalYScale
                    }
                ]),
                withKey: "poci_headbutt_attack"
            )
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
