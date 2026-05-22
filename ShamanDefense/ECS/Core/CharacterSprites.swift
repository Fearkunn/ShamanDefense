//
//  CharacterSprites.swift
//  ShamanDefense
//

import SpriteKit

enum CharacterSprites {
    static let spriteHeight: CGFloat = 36
    static var renderHeight: CGFloat = spriteHeight

    private static var textureCache: [String: SKTexture] = [:]

    static func cachedTexture(named name: String) -> SKTexture {
        if let tex = textureCache[name] { return tex }
        let tex = SKTexture(imageNamed: name)
        textureCache[name] = tex
        return tex
    }

    static func makeGhostAura(yOffset: CGFloat) -> SKShapeNode {
        let aura = SKShapeNode(
            ellipseOf: CGSize(
                width: GhostMetrics.diameter + 6,
                height: (GhostMetrics.diameter + 6) * 0.38
            )
        )
        aura.fillColor = .black
        aura.strokeColor = .clear
        aura.alpha = 0.20
        aura.position = CGPoint(x: 0, y: yOffset)
        aura.zPosition = 0
        return aura
    }

    static func texture(for id: GhostID, facing: FacingDirection) -> SKTexture {
        cachedTexture(named: assetName(for: id, facing: facing))
    }

    static func size(for texture: SKTexture, height: CGFloat = renderHeight) -> CGSize {
        let s = texture.size()
        guard s.height > 0 else { return CGSize(width: height, height: height) }
        return CGSize(width: height * (s.width / s.height), height: height)
    }

    static func cardImageName(for id: GhostID) -> String {
        return "\(id.rawValue)_card"
    }

    private static func assetName(for id: GhostID, facing: FacingDirection) -> String {
        let orient: String
        switch facing {
        case .up:            orient = "top"
        case .down:          orient = "bottom"
        case .left, .right:  orient = "left"
        }
        if id == .yayang && (facing == .left || facing == .right) {
            return "yayang_top"
        }
        return "\(id.rawValue)_\(orient)"
    }
}
