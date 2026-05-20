//
//  HumanEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class HumanEntity: GameEntity {
    static let moveSpeed: CGFloat = 100
    static let maxHp: CGFloat = 1

    let archetypeKind: HumanArchetype

    init(waypoints: [CGPoint],
         archetype: HumanArchetype = .blue,
         hpMultiplier: CGFloat = 1.0) {
        self.archetypeKind = archetype
        super.init(archetype: .human)

        let leftFrames = Self.frames(direction: "left", archetype: archetype)
        let topFrames = Self.frames(direction: "top", archetype: archetype)
        let bottomFrames = Self.frames(direction: "bottom", archetype: archetype)

        let root = SKNode()
        root.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        let sprite = SKSpriteNode(texture: leftFrames[0], size: CharacterSprites.size(for: bottomFrames[0]))
        sprite.position = CGPoint(x: 0, y: CharacterSprites.renderHeight * 0.15)
        if archetype.isFast {
            sprite.color = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            sprite.colorBlendFactor = 0.25
            sprite.alpha = 0.85
        }
        root.addChild(sprite)

        addComponent(SpriteComponent(node: root))
        addComponent(TeamComponent(team: .human))
        addComponent(HealthComponent(maxHp: Self.maxHp * archetype.hpMultiplier * hpMultiplier))
        addComponent(SpriteAnimationComponent(
            sprite: sprite,
            leftFrames: leftFrames,
            upFrames: topFrames,
            downFrames: bottomFrames
        ))
        addComponent(PathFollowComponent(
            waypoints: waypoints,
            speed: Self.moveSpeed * archetype.speedMultiplier
        ))
        addComponent(EffectsComponent())
        addComponent(StateMachineComponent(
            states: [HumanWalkingState(), HumanSlowedState(), HumanFrozenState()],
            initialState: HumanWalkingState.self
        ))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private static func frames(direction: String, archetype: HumanArchetype) -> [SKTexture] {
        let suffix = archetype.spriteSuffix.map { "_\($0)" } ?? ""
        return [
            SKTexture(imageNamed: "human_\(direction)_1\(suffix)"),
            SKTexture(imageNamed: "human_\(direction)_2\(suffix)")
        ]
    }
}
