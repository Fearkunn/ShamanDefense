//
//  PathFollowComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathFollowComponent: GKComponent {
    private let waypoints: [CGPoint]
    let baseSpeed: CGFloat
    var speedMultiplier: CGFloat = 1
    var frozen: Bool = false
    var onArrive: (() -> Void)?

    private var segmentIndex: Int = 0
    private var arrived: Bool = false

    init(waypoints: [CGPoint], speed: CGFloat) {
        self.waypoints = waypoints
        self.baseSpeed = speed
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func didAddToEntity() {
        guard let sprite = sprite, waypoints.count >= 2 else { return }
        sprite.position = waypoints[0]
        face(toward: waypoints[1])
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard !arrived, !frozen,
              let sprite = sprite,
              segmentIndex + 1 < waypoints.count else { return }

        let target = waypoints[segmentIndex + 1]
        var step = baseSpeed * speedMultiplier * CGFloat(seconds)
        var pos = sprite.position

        while step > 0 && segmentIndex + 1 < waypoints.count {
            let next = waypoints[segmentIndex + 1]
            let dx = next.x - pos.x
            let dy = next.y - pos.y
            let dist = hypot(dx, dy)
            if step >= dist {
                pos = next
                step -= dist
                segmentIndex += 1
                if segmentIndex + 1 < waypoints.count {
                    face(toward: waypoints[segmentIndex + 1], from: pos)
                }
            } else {
                pos.x += dx / dist * step
                pos.y += dy / dist * step
                step = 0
            }
        }

        sprite.position = pos
        _ = target

        if segmentIndex + 1 >= waypoints.count {
            arrived = true
            onArrive?()
        }
    }

    private var sprite: SKNode? {
        entity?.component(ofType: SpriteComponent.self)?.node
    }

    private func face(toward target: CGPoint, from: CGPoint? = nil) {
        guard let sprite = sprite,
              let anim = entity?.component(ofType: SpriteAnimationComponent.self) else { return }
        let origin = from ?? sprite.position
        anim.face(dx: target.x - origin.x, dy: target.y - origin.y)
    }
}
