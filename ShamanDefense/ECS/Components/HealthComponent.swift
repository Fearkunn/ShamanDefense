//
//  HealthComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class HealthComponent: GKComponent {
    private(set) var hp: CGFloat
    let maxHp: CGFloat
    var onDeath: (() -> Void)?

    var isAlive: Bool { hp > 0 }

    init(maxHp: CGFloat) {
        self.hp = maxHp
        self.maxHp = maxHp
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func takeDamage(_ amount: CGFloat) {
        guard hp > 0 else { return }
        hp = max(0, hp - amount)
        if hp <= 0 {
            onDeath?()
        }
    }
}
