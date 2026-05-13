//
//  SpriteAnimationComponent.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

enum FacingDirection {
    case left, right, up, down
}

final class SpriteAnimationComponent: GKComponent {
    let sprite: SKSpriteNode
    private let leftFrames: [SKTexture]
    private let upFrames: [SKTexture]
    private let downFrames: [SKTexture]
    private let timePerFrame: TimeInterval
    private var current: FacingDirection?

    init(sprite: SKSpriteNode,
         leftFrames: [SKTexture],
         upFrames: [SKTexture],
         downFrames: [SKTexture],
         timePerFrame: TimeInterval = 0.25) {
        self.sprite = sprite
        self.leftFrames = leftFrames
        self.upFrames = upFrames
        self.downFrames = downFrames
        self.timePerFrame = timePerFrame
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func face(dx: CGFloat, dy: CGFloat) {
        let direction: FacingDirection
        let xScale: CGFloat
        if abs(dx) >= abs(dy) {
            direction = dx < 0 ? .left : .right
            xScale = dx < 0 ? 1 : -1
        } else {
            direction = dy > 0 ? .up : .down
            xScale = 1
        }
        sprite.xScale = xScale
        guard current != direction else { return }
        current = direction
        let frames: [SKTexture]
        switch direction {
        case .left, .right: frames = leftFrames
        case .up:           frames = upFrames
        case .down:         frames = downFrames
        }
        if let first = frames.first {
            sprite.size = CharacterSprites.size(for: first, height: sprite.size.height)
        }
        sprite.removeAction(forKey: "walk")
        sprite.run(
            .repeatForever(.animate(with: frames, timePerFrame: timePerFrame, resize: false, restore: false)),
            withKey: "walk"
        )
    }

    func stopAnimating() {
        sprite.removeAction(forKey: "walk")
        current = nil
    }
}
