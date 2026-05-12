//
//  ProximityTriggerComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class ProximityTriggerComponent: GKComponent {
    let triggerRadius: CGFloat
    var armed: Bool = true
    var onTrigger: ((GameEntity) -> Void)?

    init(triggerRadius: CGFloat) {
        self.triggerRadius = triggerRadius
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func update(deltaTime seconds: TimeInterval) {
        guard armed,
              let entity,
              let pos = entity.component(ofType: SpriteComponent.self)?.position,
              let scene = entity.component(ofType: SpriteComponent.self)?.node.scene as? GameScene else { return }

        for human in scene.registry.humans {
            guard let h = human.component(ofType: HealthComponent.self), h.isAlive,
                  let hp = human.component(ofType: SpriteComponent.self)?.position else { continue }
            if hypot(hp.x - pos.x, hp.y - pos.y) <= triggerRadius {
                armed = false
                onTrigger?(human)
                return
            }
        }
    }
}
