//
//  HumanNode.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit

class HumanNode: SKNode {
    private let moveSpeed: CGFloat = 100
    private(set) var hp: CGFloat = 1
    var onDefeat: (() -> Void)?

    private static let walkLeft   = [SKTexture(imageNamed: "human_left_1"),   SKTexture(imageNamed: "human_left_2")]
    private static let walkTop    = [SKTexture(imageNamed: "human_top_1"),    SKTexture(imageNamed: "human_top_2")]
    private static let walkBottom = [SKTexture(imageNamed: "human_bottom_1"), SKTexture(imageNamed: "human_bottom_2")]
    private static let spriteSize = CGSize(width: 32, height: 50)

    private let sprite: SKSpriteNode

    override init() {
        sprite = SKSpriteNode(texture: Self.walkLeft[0], size: Self.spriteSize)
        super.init()
        constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        addChild(sprite)
        face(dx: -1, dy: 0)
    }

    required init?(coder: NSCoder) { fatalError() }

    func takeDamage(_ amount: CGFloat) {
        guard hp > 0 else { return }
        hp = max(0, hp - amount)
        guard hp <= 0 else { return }
        removeAllActions()
        onDefeat?()
        run(.sequence([.fadeOut(withDuration: 0.15), .removeFromParent()]))
        }
    }

    func applySlow(factor: CGFloat, duration: TimeInterval) {
        speed = factor
        run(.sequence([
            .wait(forDuration: duration),
            .run { [weak self] in self?.speed = 1 }
        ]), withKey: "slow")
    }

    func applyFreeze(duration: TimeInterval) {
        isPaused = true
        run(.sequence([
            .wait(forDuration: duration),
            .run { [weak self] in self?.isPaused = false }
        ]), withKey: "freeze")
    }

    func followPath(_ waypoints: [CGPoint], onReachFinish: (() -> Void)? = nil) {
        guard waypoints.count > 1 else { return }
        position = waypoints[0]

        var steps: [SKAction] = []
        for i in 0..<waypoints.count - 1 {
            let from = waypoints[i]
            let to   = waypoints[i + 1]
            let dx   = to.x - from.x
            let dy   = to.y - from.y
            let duration = TimeInterval(hypot(dx, dy) / moveSpeed)

            steps.append(.run { [weak self] in self?.face(dx: dx, dy: dy) })
            steps.append(.move(to: to, duration: duration))
        }
        if let onReachFinish {
            steps.append(.run { onReachFinish() })
        }
        steps.append(.removeFromParent())
        run(.sequence(steps))
    }

    private func face(dx: CGFloat, dy: CGFloat) {
        let frames: [SKTexture]
        let xScale: CGFloat
        if abs(dx) >= abs(dy) {
            frames = Self.walkLeft
            xScale = dx < 0 ? 1 : -1
        } else {
            frames = dy > 0 ? Self.walkTop : Self.walkBottom
            xScale = 1
        }
        sprite.xScale = xScale
        sprite.removeAction(forKey: "walk")
        sprite.run(
            .repeatForever(.animate(with: frames, timePerFrame: 0.25, resize: false, restore: false)),
            withKey: "walk"
        )
    }
}
