//
//  SpawnerComponent.swift
//  ShamanDefense
//

import GameplayKit

final class SpawnerComponent: GKComponent {
    var interval: TimeInterval
    var accum: TimeInterval
    var spawn: () -> Void

    init(interval: TimeInterval, spawn: @escaping () -> Void) {
        self.interval = interval
        self.accum = interval
        self.spawn = spawn
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
