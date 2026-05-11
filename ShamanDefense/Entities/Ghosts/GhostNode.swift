//
//  GhostNode.swift
//  ShamanDefense
//

import SpriteKit

class GhostNode: SKShapeNode {
    static let diameter: CGFloat = GhostMetrics.diameter

    init(displayName: String, fillColor: SKColor) {
        super.init()
        let r = Self.diameter / 2
        path = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: Self.diameter, height: Self.diameter), transform: nil)
        self.fillColor = fillColor
        strokeColor = SKColor.black.withAlphaComponent(0.4)
        lineWidth = 1

        let label = SKLabelNode(text: displayName)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 10
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
