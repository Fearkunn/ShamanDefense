//
//  EntityFactory.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

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
        entity.addComponent(StateMachineComponent(
            states: [HumanWalkingState()],
            initialState: HumanWalkingState.self
        ))

        return entity
    }
}
