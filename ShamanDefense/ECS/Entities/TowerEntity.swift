//
//  TowerEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit
import SwiftUI

final class TowerEntity: GameEntity {
    let character: CharacterData

    init(character: CharacterData) {
        guard let stats = character.tower else {
            fatalError("TowerEntity requires character.tower stats (id=\(character.id))")
        }
        self.character = character
        super.init(archetype: .tower)

        let color = SKColor(character.tint)
        let texture = CharacterSprites.texture(for: character.id, facing: .down)
        let sprite = SKSpriteNode(texture: texture, size: CharacterSprites.size(for: texture))
        let root = SKNode()
        let aura = SKShapeNode(
            ellipseOf: CGSize(
                width: GhostMetrics.diameter + 6,
                height: (GhostMetrics.diameter + 6) * 0.38
            )
        )
        aura.fillColor = .black
        aura.strokeColor = .clear
        aura.alpha = 0.20
        aura.position = CGPoint(x: 0, y: -CharacterSprites.spriteHeight * 0.50)
        aura.zPosition = 0
        sprite.zPosition = 1
        root.addChild(aura)
        root.addChild(sprite)

        addComponent(SpriteComponent(node: root))
        addComponent(DirectionalSpriteComponent(sprite: sprite, id: character.id))
        addComponent(TeamComponent(team: .ghost))
        addComponent(PlacementBlockerComponent(radius: GhostMetrics.diameter / 2))
        addComponent(TargetingComponent(range: stats.range))
        addComponent(FiringComponent(fireInterval: stats.fireInterval))
        addComponent(ProjectileLauncherComponent(
            sourceGhostID: character.id,
            projectileSpeed: stats.projectileSpeed,
            damage: stats.damage,
            aoeRadius: stats.aoeRadius,
            color: color
        ))
        addComponent(StateMachineComponent(
            states: [
                TowerIdleState(),
                TowerAcquiringState(),
                TowerFiringState(),
                TowerCooldownState(),
            ],
            initialState: TowerIdleState.self
        ))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
