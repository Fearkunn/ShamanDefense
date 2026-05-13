//
//  DirectionalSpriteComponent.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class DirectionalSpriteComponent: GKComponent {
    let sprite: SKSpriteNode
    let id: GhostID
    private var current: FacingDirection?

    init(sprite: SKSpriteNode, id: GhostID, initialFacing: FacingDirection = .down) {
        self.sprite = sprite
        self.id = id
        super.init()
        setFacing(initialFacing)
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
        sprite.xScale = abs(sprite.xScale) * (xScale < 0 ? -1 : 1)
        guard current != direction else { return }
        current = direction
        applyTexture(for: direction)
    }

    func setFacing(_ direction: FacingDirection) {
        current = direction
        applyTexture(for: direction)
        if direction == .right {
            sprite.xScale = -abs(sprite.xScale)
        } else {
            sprite.xScale = abs(sprite.xScale)
        }
    }

    private func applyTexture(for direction: FacingDirection) {
        let tex = CharacterSprites.texture(for: id, facing: direction)
        sprite.texture = tex
        sprite.size = CharacterSprites.size(for: tex)
    }
}
