//
//  WaveManagerEntity.swift
//  ShamanDefense
//

import GameplayKit

final class WaveManagerEntity: GameEntity {
    init(config: WaveScalingConfig = .default) {
        super.init(archetype: .global)
        addComponent(WaveManagerComponent(config: config))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
