//
//  ProjectileEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class ProjectileEntity: GameEntity {
    init(from origin: CGPoint, target: GameEntity, launcher: ProjectileLauncherComponent) {
        super.init(archetype: .projectile)

        let node = SKShapeNode(circleOfRadius: 4)
        node.fillColor = launcher.color
        node.strokeColor = .clear
        node.position = origin
        node.zPosition = 5

        addComponent(SpriteComponent(node: node))
        addComponent(HomingComponent(target: target, speed: launcher.projectileSpeed, hitRadius: launcher.hitRadius))
        addComponent(DamageOnHitComponent(damage: launcher.damage, aoeRadius: launcher.aoeRadius, color: launcher.color))
        addComponent(LifetimeComponent(duration: 3))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
