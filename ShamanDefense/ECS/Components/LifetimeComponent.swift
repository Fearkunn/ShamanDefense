//
//  LifetimeComponent.swift
//  ShamanDefense
//

import GameplayKit

final class LifetimeComponent: GKComponent {
    var remaining: TimeInterval
    var onExpire: (() -> Void)?

    init(duration: TimeInterval) {
        self.remaining = duration
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
