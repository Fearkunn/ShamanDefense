//
//  PathEntity.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathEntity: GameEntity {
    init(waypoints: [CGPoint], tileRects: [CGRect] = []) {
        super.init(archetype: .scenery)
        addComponent(PathComponent(waypoints: waypoints, tileRects: tileRects))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
