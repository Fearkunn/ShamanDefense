//
//  ShamanHUD.swift
//  ShamanDefense
//

import SpriteKit

final class ShamanHUD: SKNode {

    private let counterNode: SKSpriteNode
    private let spiritLabel: GameLabelNode

    init(anchor: CGPoint) {
        let shaman = SKSpriteNode(imageNamed: "shaman")
        shaman.setScale(0.8)
        shaman.position = CGPoint(x: 0, y: -40)
        shaman.zPosition = 10

        counterNode = SKSpriteNode(imageNamed: "spirit_counter")
        counterNode.size = CGSize(width: 110, height: 50)
        counterNode.position = CGPoint(x: -5, y: -110)
        counterNode.zPosition = 11

        spiritLabel = GameLabelNode(text: "0", fontSize: 20, color: .black)
        spiritLabel.position = CGPoint(x: 5, y: 3)
        spiritLabel.zPosition = 12

        super.init()

        position = anchor
        counterNode.addChild(spiritLabel)
        addChild(shaman)
        addChild(counterNode)

        shaman.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 10, duration: 1),
            .moveBy(x: 0, y: -10, duration: 1)
        ])))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }

    func updateSpirit(_ value: Int) {
        spiritLabel.text = "\(value)"
        counterNode.run(.sequence([
            .scale(to: 1.15, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ]))
    }
}
