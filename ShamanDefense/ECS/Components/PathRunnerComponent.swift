//
//  PathRunnerComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathRunnerComponent: GKComponent {
    var waypoints: [CGPoint] = []
    let speed: CGFloat
    var active: Bool = false
    var onComplete: (() -> Void)?

    var segmentIndex: Int = 0
    var completed: Bool = false

    init(speed: CGFloat) {
        self.speed = speed
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func configure(waypoints: [CGPoint]) {
        self.waypoints = waypoints
        segmentIndex = 0
        completed = false
    }
}
