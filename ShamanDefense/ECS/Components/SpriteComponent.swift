//
//  SpriteComponent.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class SpriteComponent: GKComponent {
    let node: SKNode

    init(node: SKNode) {
        self.node = node
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }
}
