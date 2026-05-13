//
//  HomingComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class HomingComponent: GKComponent {
    weak var target: GameEntity?
    let speed: CGFloat
    let hitRadius: CGFloat
    var onImpact: ((CGPoint, GameEntity?) -> Void)?
    var onTargetLost: (() -> Void)?

    init(target: GameEntity, speed: CGFloat, hitRadius: CGFloat) {
        self.target = target
        self.speed = speed
        self.hitRadius = hitRadius
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
