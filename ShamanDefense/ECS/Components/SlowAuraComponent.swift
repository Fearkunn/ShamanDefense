//
//  SlowAuraComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class SlowAuraComponent: GKComponent {
    let radius: CGFloat
    let factor: CGFloat
    let duration: TimeInterval
    let scanInterval: TimeInterval
    var active: Bool = false
    var accum: TimeInterval = 0

    init(radius: CGFloat, factor: CGFloat, duration: TimeInterval, scanInterval: TimeInterval = 0.1) {
        self.radius = radius
        self.factor = factor
        self.duration = duration
        self.scanInterval = scanInterval
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
