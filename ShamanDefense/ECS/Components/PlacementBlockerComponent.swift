//
//  PlacementBlockerComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PlacementBlockerComponent: GKComponent {
    let radius: CGFloat

    init(radius: CGFloat) {
        self.radius = radius
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
