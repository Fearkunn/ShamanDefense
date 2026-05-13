//
//  FreezeAuraComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class FreezeAuraComponent: GKComponent {
    let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func detonate(in registry: EntityRegistry) {
        for human in registry.humans {
            guard let health = human.component(ofType: HealthComponent.self), health.isAlive,
                  let effects = human.component(ofType: EffectsComponent.self) else { continue }
            effects.applyFreeze(duration: duration)
        }
    }
}
