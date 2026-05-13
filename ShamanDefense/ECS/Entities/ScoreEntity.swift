//
//  ScoreEntity.swift
//  ShamanDefense
//

import GameplayKit

final class ScoreEntity: GameEntity {
    override init(archetype: EntityArchetype = .scenery) {
        super.init(archetype: archetype)
        addComponent(ScoreComponent())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
