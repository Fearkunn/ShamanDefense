//
//  HumanEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class HumanEntity: GameEntity {
    private static let leftFrames   = [SKTexture(imageNamed: "human_left_1"),   SKTexture(imageNamed: "human_left_2")]
    private static let topFrames    = [SKTexture(imageNamed: "human_top_1"),    SKTexture(imageNamed: "human_top_2")]
    private static let bottomFrames = [SKTexture(imageNamed: "human_bottom_1"), SKTexture(imageNamed: "human_bottom_2")]
    private static let spriteSize   = CharacterSprites.size(for: bottomFrames[0])
    static let moveSpeed: CGFloat = 100
    static let maxHp: CGFloat = 1

    init(waypoints: [CGPoint]) {
        super.init(archetype: .human)

        let root = SKNode()
        root.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        let sprite = SKSpriteNode(texture: Self.leftFrames[0], size: Self.spriteSize)
        root.addChild(sprite)

        addComponent(SpriteComponent(node: root))
        addComponent(TeamComponent(team: .human))
        addComponent(HealthComponent(maxHp: Self.maxHp))
        addComponent(SpriteAnimationComponent(
            sprite: sprite,
            leftFrames: Self.leftFrames,
            upFrames: Self.topFrames,
            downFrames: Self.bottomFrames
        ))
        addComponent(PathFollowComponent(waypoints: waypoints, speed: Self.moveSpeed))
        addComponent(EffectsComponent())
        addComponent(StateMachineComponent(
            states: [HumanWalkingState(), HumanSlowedState(), HumanFrozenState()],
            initialState: HumanWalkingState.self
        ))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
