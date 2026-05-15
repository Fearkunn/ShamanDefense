//
//  GameStateEntity.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 13/05/26.
//

import GameplayKit

final class GameStateEntity: GameEntity {
    init() {
        super.init(archetype: .global)
        addComponent(PauseComponent())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
