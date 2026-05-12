//
//  EntityFactory.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit
import SwiftUI

enum EntityFactory {

    private static let humanLeftFrames   = [SKTexture(imageNamed: "human_left_1"),   SKTexture(imageNamed: "human_left_2")]
    private static let humanTopFrames    = [SKTexture(imageNamed: "human_top_1"),    SKTexture(imageNamed: "human_top_2")]
    private static let humanBottomFrames = [SKTexture(imageNamed: "human_bottom_1"), SKTexture(imageNamed: "human_bottom_2")]
    private static let humanSpriteSize   = CGSize(width: 32, height: 50)
    private static let humanMoveSpeed: CGFloat = 100
    private static let humanMaxHp: CGFloat = 1

    static func makeHuman(waypoints: [CGPoint]) -> GameEntity {
        let entity = GameEntity(archetype: .human)

        let root = SKNode()
        root.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        let sprite = SKSpriteNode(texture: humanLeftFrames[0], size: humanSpriteSize)
        root.addChild(sprite)

        entity.addComponent(SpriteComponent(node: root))
        entity.addComponent(TeamComponent(team: .human))
        entity.addComponent(HealthComponent(maxHp: humanMaxHp))
        entity.addComponent(SpriteAnimationComponent(
            sprite: sprite,
            leftFrames: humanLeftFrames,
            upFrames: humanTopFrames,
            downFrames: humanBottomFrames
        ))
        entity.addComponent(PathFollowComponent(waypoints: waypoints, speed: humanMoveSpeed))
        entity.addComponent(EffectsComponent())
        entity.addComponent(StateMachineComponent(
            states: [
                HumanWalkingState(),
                HumanSlowedState(),
                HumanFrozenState(),
                HumanDyingState(),
            ],
            initialState: HumanWalkingState.self
        ))

        return entity
    }

    static func makeTrap(_ character: CharacterData, waypoints: [CGPoint]) -> GameEntity {
        guard let stats = character.trap else {
            fatalError("makeTrap requires character.trap stats (id=\(character.id))")
        }
        let entity = GameEntity(archetype: .trap)
        let body = makeGhostBody(displayName: character.name, fillColor: SKColor(character.tint))

        entity.addComponent(SpriteComponent(node: body))
        entity.addComponent(TeamComponent(team: .ghost))
        entity.addComponent(ProximityTriggerComponent(triggerRadius: stats.triggerRadius))

        var states: [GKState] = [TrapArmedState(), TrapSpentState()]

        switch character.id {
        case .yayang:
            if let freeze = stats.freezeDuration {
                entity.addComponent(FreezeAuraComponent(duration: freeze))
            }
            states.append(YayangTriggeredState())
        case .yuyul:
            if let runSpeed = stats.runSpeed {
                entity.addComponent(PathRunnerComponent(waypoints: waypoints, speed: runSpeed))
            }
            if let r = stats.slowRadius, let f = stats.slowFactor, let d = stats.slowDuration {
                entity.addComponent(SlowAuraComponent(radius: r, factor: f, duration: d))
            }
            states.append(YuyulTriggeredState())
        default:
            fatalError("Unknown trap id \(character.id)")
        }

        entity.addComponent(StateMachineComponent(states: states, initialState: TrapArmedState.self))
        return entity
    }

    static func makeTower(_ character: CharacterData) -> GameEntity {
        guard let stats = character.tower else {
            fatalError("makeTower requires character.tower stats (id=\(character.id))")
        }
        let entity = GameEntity(archetype: .tower)

        let color = SKColor(character.tint)
        let body = makeGhostBody(displayName: character.name, fillColor: color)

        entity.addComponent(SpriteComponent(node: body))
        entity.addComponent(TeamComponent(team: .ghost))
        entity.addComponent(TargetingComponent(range: stats.range))
        entity.addComponent(FiringComponent(fireInterval: stats.fireInterval))
        entity.addComponent(ProjectileLauncherComponent(
            projectileSpeed: stats.projectileSpeed,
            damage: stats.damage,
            aoeRadius: stats.aoeRadius,
            color: color
        ))
        entity.addComponent(StateMachineComponent(
            states: [
                TowerIdleState(),
                TowerAcquiringState(),
                TowerFiringState(),
                TowerCooldownState(),
            ],
            initialState: TowerIdleState.self
        ))

        return entity
    }

    static func makeProjectile(from origin: CGPoint,
                               target: GameEntity,
                               launcher: ProjectileLauncherComponent) -> GameEntity {
        let entity = GameEntity(archetype: .projectile)

        let node = SKShapeNode(circleOfRadius: 4)
        node.fillColor = launcher.color
        node.strokeColor = .clear
        node.position = origin
        node.zPosition = 5

        entity.addComponent(SpriteComponent(node: node))
        entity.addComponent(HomingComponent(target: target, speed: launcher.projectileSpeed, hitRadius: launcher.hitRadius))
        entity.addComponent(DamageOnHitComponent(damage: launcher.damage, aoeRadius: launcher.aoeRadius, color: launcher.color))
        entity.addComponent(LifetimeComponent(duration: 3))

        return entity
    }

    static func makeGhostBody(displayName: String, fillColor: SKColor) -> SKShapeNode {
        let d = GhostMetrics.diameter
        let r = d / 2
        let node = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -r, y: -r, width: d, height: d), transform: nil))
        node.fillColor = fillColor
        node.strokeColor = SKColor.black.withAlphaComponent(0.4)
        node.lineWidth = 1

        let label = SKLabelNode(text: displayName)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 10
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        return node
    }
}
