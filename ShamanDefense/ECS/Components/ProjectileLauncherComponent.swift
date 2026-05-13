//
//  ProjectileLauncherComponent.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class ProjectileLauncherComponent: GKComponent {
    let projectileSpeed: CGFloat
    let damage: CGFloat
    let aoeRadius: CGFloat?
    let color: SKColor
    let hitRadius: CGFloat

    init(projectileSpeed: CGFloat,
         damage: CGFloat,
         aoeRadius: CGFloat?,
         color: SKColor,
         hitRadius: CGFloat = 14) {
        self.projectileSpeed = projectileSpeed
        self.damage = damage
        self.aoeRadius = aoeRadius
        self.color = color
        self.hitRadius = hitRadius
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
