//
//  TrapEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit
import SwiftUI

final class TrapEntity: GameEntity {
    let character: CharacterData

    init(character: CharacterData, pathWaypoints: [CGPoint]) {
        guard let stats = character.trap else {
            fatalError("TrapEntity requires character.trap stats (id=\(character.id))")
        }
        self.character = character
        super.init(archetype: .trap)

        let texture = CharacterSprites.texture(for: character.id, facing: .down)
        let sprite = SKSpriteNode(texture: texture, size: CharacterSprites.size(for: texture))
        let root = SKNode()
        let aura = SKShapeNode(
            ellipseOf: CGSize(
                width: GhostMetrics.diameter + 6,
                height: (GhostMetrics.diameter + 6) * 0.38
            )
        )
        aura.fillColor = .black
        aura.strokeColor = .clear
        aura.alpha = 0.20
        aura.position = CGPoint(x: 0, y: -CharacterSprites.spriteHeight * 0.50)
        aura.zPosition = 0
        sprite.zPosition = 1
        root.addChild(aura)
        root.addChild(sprite)

        addComponent(SpriteComponent(node: root))
        addComponent(DirectionalSpriteComponent(sprite: sprite, id: character.id))
        addComponent(TeamComponent(team: .ghost))
        addComponent(PlacementBlockerComponent(radius: GhostMetrics.diameter / 2))
        addComponent(ProximityTriggerComponent(triggerRadius: stats.triggerRadius))

        var states: [GKState] = [TrapArmedState(), TrapSpentState()]

        switch character.id {
        case .yayang:
            if let freeze = stats.freezeDuration {
                addComponent(FreezeAuraComponent(duration: freeze))
            }
            states.append(YayangTriggeredState())
        case .yuyul:
            if let runSpeed = stats.runSpeed {
                let runner = PathRunnerComponent(speed: runSpeed)
                runner.configure(waypoints: pathWaypoints)
                addComponent(runner)
            }
            if let r = stats.slowRadius, let f = stats.slowFactor, let d = stats.slowDuration {
                addComponent(SlowAuraComponent(radius: r, factor: f, duration: d))
            }
            states.append(YuyulTriggeredState())
        default:
            fatalError("Unknown trap id \(character.id)")
        }

        addComponent(StateMachineComponent(states: states, initialState: TrapArmedState.self))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
