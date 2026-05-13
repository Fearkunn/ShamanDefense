//
//  CharacterSprites.swift
//  ShamanDefense
//

import SpriteKit

enum CharacterSprites {
    static let spriteHeight: CGFloat = 36

    static func texture(for id: GhostID, facing: FacingDirection) -> SKTexture {
        SKTexture(imageNamed: assetName(for: id, facing: facing))
    }

    static func size(for texture: SKTexture, height: CGFloat = spriteHeight) -> CGSize {
        let s = texture.size()
        guard s.height > 0 else { return CGSize(width: height, height: height) }
        return CGSize(width: height * (s.width / s.height), height: height)
    }

    static func cardImageName(for id: GhostID) -> String {
        switch id {
        case .gugun, .yuyul, .yayang: return "\(id.rawValue)_card"
        case .keti, .poci:            return "\(id.rawValue)_bottom"
        }
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
