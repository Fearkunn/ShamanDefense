//
//  PathEntity.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathEntity: GameEntity {
    init(waypoints: [CGPoint], halfWidth: CGFloat) {
        super.init(archetype: .scenery)
        addComponent(PathComponent(waypoints: waypoints, halfWidth: halfWidth))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
