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
}
