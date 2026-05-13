//
//  GhostBody.swift
//  ShamanDefense
//

import SpriteKit

enum GhostBody {
    static func make(displayName: String, fillColor: SKColor) -> SKShapeNode {
        let d = GhostMetrics.diameter
        let r = d / 2
        let node = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -r, y: -r, width: d, height: d), transform: nil))
        node.fillColor = fillColor
        node.strokeColor = SKColor.black.withAlphaComponent(0.4)
        node.lineWidth = 1

        let label = SKLabelNode(text: displayName)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 10
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        return node
    }
}
