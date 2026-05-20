//
//  GhostAttackProfileComponent.swift
//  ShamanDefense
//

import GameplayKit

enum GhostAttackStyle {
    case projectile
    case pociHeadbutt
    case ketiScream
    case gugunJump
}

final class GhostAttackProfileComponent: GKComponent {
    let style: GhostAttackStyle

    init(style: GhostAttackStyle) {
        self.style = style
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
