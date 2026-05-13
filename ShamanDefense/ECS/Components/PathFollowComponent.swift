//
//  PathFollowComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathFollowComponent: GKComponent {
    let waypoints: [CGPoint]
    let baseSpeed: CGFloat
    var speedMultiplier: CGFloat = 1
    var frozen: Bool = false
    var onArrive: (() -> Void)?

    var segmentIndex: Int = 0
    var arrived: Bool = false

    init(waypoints: [CGPoint], speed: CGFloat) {
        self.waypoints = waypoints
        self.baseSpeed = speed
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
