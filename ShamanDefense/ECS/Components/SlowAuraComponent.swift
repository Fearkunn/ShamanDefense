//
//  SlowAuraComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class SlowAuraComponent: GKComponent {
    let radius: CGFloat
    let factor: CGFloat
    let duration: TimeInterval
    let scanInterval: TimeInterval
    var active: Bool = false

    private var accum: TimeInterval = 0

    init(radius: CGFloat, factor: CGFloat, duration: TimeInterval, scanInterval: TimeInterval = 0.1) {
        self.radius = radius
        self.factor = factor
        self.duration = duration
        self.scanInterval = scanInterval
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func update(deltaTime seconds: TimeInterval) {
        guard active,
              let pos = entity?.component(ofType: SpriteComponent.self)?.position,
              let scene = entity?.component(ofType: SpriteComponent.self)?.node.scene as? GameScene else { return }

        accum += seconds
        guard accum >= scanInterval else { return }
        accum = 0

        for human in scene.registry.humans {
            guard let hp = human.component(ofType: SpriteComponent.self)?.position,
                  let health = human.component(ofType: HealthComponent.self), health.isAlive,
                  let effects = human.component(ofType: EffectsComponent.self) else { continue }
            if hypot(hp.x - pos.x, hp.y - pos.y) <= radius {
                effects.applySlow(factor: factor, duration: duration)
            }
        }
    }
}
