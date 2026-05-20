//
//  HumanEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class HumanEntity: GameEntity {
    static let moveSpeed: CGFloat = 100
    static let maxHp: CGFloat = 1
    static let deathAnimationDuration: TimeInterval = 0.65

    let archetypeKind: HumanArchetype
    private weak var bodySprite: SKSpriteNode?

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
        self.bodySprite = sprite

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

    func playDeathAnimation(completion: @escaping () -> Void) {
        if let pf = component(ofType: PathFollowComponent.self) {
            pf.frozen = true
            pf.arrived = true
        }
        component(ofType: SpriteAnimationComponent.self)?.stopAnimating()

        guard let root = component(ofType: SpriteComponent.self)?.node else {
            completion()
            return
        }
        root.removeAllActions()

        let duration = Self.deathAnimationDuration
        if let body = bodySprite {
            let deadTexture = SKTexture(imageNamed: "human_dead")
            body.texture = deadTexture
            body.size = CharacterSprites.size(for: deadTexture, height: CharacterSprites.spriteHeight)
            body.removeAllActions()
            body.alpha = 1
            body.setScale(1.0)
            body.run(.group([
                .moveBy(x: 0, y: 26, duration: duration),
                .fadeOut(withDuration: duration),
                .scale(to: 1.08, duration: duration)
            ]))
        }

        root.run(.sequence([
            .wait(forDuration: duration),
            .run(completion)
        ]))
    }

    private static func frames(direction: String, archetype: HumanArchetype) -> [SKTexture] {
        let suffix = archetype.spriteSuffix.map { "_\($0)" } ?? ""
        return [
            SKTexture(imageNamed: "human_\(direction)_1\(suffix)"),
            SKTexture(imageNamed: "human_\(direction)_2\(suffix)")
        ]
    }
}
