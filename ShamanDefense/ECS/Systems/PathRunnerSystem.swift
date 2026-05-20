//
//  PathRunnerSystem.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics
import SpriteKit

final class PathRunnerSystem: ComponentSystem<PathRunnerComponent> {
    override func update(deltaTime: TimeInterval) {
        for runner in components {
            tick(runner, dt: deltaTime)
        }
    }

    private func tick(_ runner: PathRunnerComponent, dt: TimeInterval) {
        guard runner.active, !runner.completed,
              let entity = runner.entity as? GameEntity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              runner.segmentIndex + 1 < runner.waypoints.count else { return }

        let previousPosition = sprite.position
        var pos = previousPosition
        var step = runner.speed * CGFloat(dt)
        let directional = entity.component(ofType: DirectionalSpriteComponent.self)
        if runner.segmentIndex + 1 < runner.waypoints.count {
            let next = runner.waypoints[runner.segmentIndex + 1]
            directional?.face(dx: next.x - pos.x, dy: next.y - pos.y)
        }

        while step > 0 && runner.segmentIndex + 1 < runner.waypoints.count {
            let next = runner.waypoints[runner.segmentIndex + 1]
            let dx = next.x - pos.x
            let dy = next.y - pos.y
            let dist = hypot(dx, dy)
            if step >= dist {
                pos = next
                step -= dist
                runner.segmentIndex += 1
                if runner.segmentIndex + 1 < runner.waypoints.count {
                    let upcoming = runner.waypoints[runner.segmentIndex + 1]
                    directional?.face(dx: upcoming.x - pos.x, dy: upcoming.y - pos.y)
                }
            } else {
                pos.x += dx / dist * step
                pos.y += dy / dist * step
                step = 0
            }
        }
        sprite.position = pos

        let movedDistance = hypot(pos.x - previousPosition.x, pos.y - previousPosition.y)
        runner.footPuffCooldown = max(0, runner.footPuffCooldown - dt)
        if movedDistance > 0.4,
           runner.footPuffCooldown <= 0,
           let trap = entity as? TrapEntity,
           trap.character.id == .yuyul,
           let scene = sprite.node.scene as? GameScene {
            spawnYuyulFootPuff(at: pos, in: scene)
            runner.footPuffCooldown = 0.04
        }

        if runner.segmentIndex + 1 >= runner.waypoints.count {
            runner.completed = true
            runner.onComplete?()
        }
    }

    private func spawnYuyulFootPuff(at position: CGPoint, in scene: GameScene) {
        let footPoint = CGPoint(
            x: position.x,
            y: position.y - CharacterSprites.spriteHeight * 0.50
        )
        let stomp = SKShapeNode(ellipseOf: CGSize(width: 22, height: 9))
        stomp.position = footPoint
        stomp.fillColor = SKColor(white: 0.16, alpha: 0.30)
        stomp.strokeColor = .clear
        stomp.zPosition = 11
        scene.fxLayer.addChild(stomp)
        stomp.run(.sequence([
            .group([
                .scaleX(to: 1.5, y: 1.2, duration: 0.14),
                .fadeOut(withDuration: 0.14)
            ]),
            .removeFromParent()
        ]))

        for puffOffset: CGFloat in [-11, -4, 4, 11] {
            let puff = SKShapeNode(circleOfRadius: 6)
            puff.position = CGPoint(x: footPoint.x + puffOffset, y: footPoint.y + 1)
            puff.fillColor = SKColor(white: 0.88, alpha: 0.52)
            puff.strokeColor = .clear
            puff.zPosition = 12
            scene.fxLayer.addChild(puff)
            puff.run(.sequence([
                .group([
                    .moveBy(x: puffOffset * 0.42, y: 2.8, duration: 0.20),
                    .scale(to: 2.0, duration: 0.20),
                    .fadeOut(withDuration: 0.20)
                ]),
                .removeFromParent()
            ]))
        }
    }
}
