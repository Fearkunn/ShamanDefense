//
//  DamageOnHitComponent.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class DamageOnHitComponent: GKComponent {
    let sourceGhostID: GhostID?
    let damage: CGFloat
    let aoeRadius: CGFloat?
    let color: SKColor

    init(sourceGhostID: GhostID? = nil, damage: CGFloat, aoeRadius: CGFloat?, color: SKColor) {
        self.sourceGhostID = sourceGhostID
        self.damage = damage
        self.aoeRadius = aoeRadius
        self.color = color
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
