//
//  TargetingComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class TargetingComponent: GKComponent {
    let range: CGFloat
    weak var currentTarget: GameEntity?

    init(range: CGFloat) {
        self.range = range
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func acquire(from origin: CGPoint, in registry: EntityRegistry) -> GameEntity? {
        var best: GameEntity?
        var bestDist = range
        for candidate in registry.humans {
            guard let health = candidate.component(ofType: HealthComponent.self), health.isAlive,
                  let pos = candidate.component(ofType: SpriteComponent.self)?.position else { continue }
            let d = hypot(pos.x - origin.x, pos.y - origin.y)
            if d <= bestDist {
                bestDist = d
                best = candidate
            }
        }
        currentTarget = best
        return best
    }
}
