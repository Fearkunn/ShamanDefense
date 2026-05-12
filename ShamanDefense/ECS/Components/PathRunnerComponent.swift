//
//  PathRunnerComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathRunnerComponent: GKComponent {
    private let waypoints: [CGPoint]
    let speed: CGFloat
    var active: Bool = false
    var onComplete: (() -> Void)?

    private var segmentIndex: Int = 0
    private var completed: Bool = false

    init(waypoints: [CGPoint], speed: CGFloat) {
        self.waypoints = waypoints
        self.speed = speed
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func update(deltaTime seconds: TimeInterval) {
        guard active, !completed,
              let sprite = entity?.component(ofType: SpriteComponent.self),
              segmentIndex + 1 < waypoints.count else { return }

        var pos = sprite.position
        var step = speed * CGFloat(seconds)

        while step > 0 && segmentIndex + 1 < waypoints.count {
            let next = waypoints[segmentIndex + 1]
            let dx = next.x - pos.x
            let dy = next.y - pos.y
            let dist = hypot(dx, dy)
            if step >= dist {
                pos = next
                step -= dist
                segmentIndex += 1
            } else {
                pos.x += dx / dist * step
                pos.y += dy / dist * step
                step = 0
            }
        }
        sprite.position = pos

        if segmentIndex + 1 >= waypoints.count {
            completed = true
            onComplete?()
        }
    }
}
