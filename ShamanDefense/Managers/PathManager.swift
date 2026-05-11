//
//  PathManager.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 07/05/26.
//

import SpriteKit

class PathManager {
    
    private let tileSize: CGFloat
    private weak var scene: SKScene?
    private(set) var waypoints: [CGPoint] = []

    var pathHalfWidth: CGFloat { tileSize / 2 }

    func isOnPath(_ point: CGPoint, tolerance: CGFloat? = nil) -> Bool {
        distanceToPath(point) <= (tolerance ?? pathHalfWidth)
    }

    func distanceToPath(_ point: CGPoint) -> CGFloat {
        guard waypoints.count >= 2 else { return .greatestFiniteMagnitude }
        var best = CGFloat.greatestFiniteMagnitude
        for i in 0..<waypoints.count - 1 {
            let d = pointToSegment(point, waypoints[i], waypoints[i + 1])
            if d < best { best = d }
        }
        return best
    }

    private func pointToSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lenSq = dx * dx + dy * dy
        guard lenSq > 0 else { return hypot(p.x - a.x, p.y - a.y) }
        var t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / lenSq
        t = max(0, min(1, t))
        let cx = a.x + t * dx
        let cy = a.y + t * dy
        return hypot(p.x - cx, p.y - cy)
    }
    
    init(scene: SKScene, tileSize: CGFloat = 36) {
        self.scene    = scene
        self.tileSize = tileSize
    }
    
    func setup() {
        buildPath()
        drawPathTiles()
    }
    
    // MARK: - Path
    
    private func buildPath() {
        guard let scene else { return }
        let w = scene.size.width
        let h = scene.size.height
        
        waypoints = [
            snap(w * 0.08, h * 0.92),
            snap(w * 0.08, h * 0.82),
            snap(w * 0.55, h * 0.82),
            snap(w * 0.55, h * 0.73),
            snap(w * 0.72, h * 0.73),
            snap(w * 0.72, h * 0.88),
            snap(w * 0.93, h * 0.88),
            snap(w * 0.93, h * 0.62),
            snap(w * 0.28, h * 0.62),
            snap(w * 0.28, h * 0.73),
            snap(w * 0.08, h * 0.73),
            snap(w * 0.08, h * 0.42),
            snap(w * 0.28, h * 0.42),
            snap(w * 0.28, h * 0.54),
            snap(w * 0.72, h * 0.54),
            snap(w * 0.72, h * 0.24),
            snap(w * 0.93, h * 0.24),
            snap(w * 0.93, h * 0.42),
            snap(w * 0.50, h * 0.42),
            snap(w * 0.50, h * 0.08)
        ]
    }
    
    private func snap(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(
            x: round(x / tileSize) * tileSize,
            y: round(y / tileSize) * tileSize
        )
    }
    
    // MARK: - Tiles
    
    private func drawPathTiles() {
        guard let scene, waypoints.count > 1 else { return }
        
        for i in 0..<waypoints.count - 1 {
            let from = waypoints[i]
            let to   = waypoints[i + 1]
            let dist = hypot(to.x - from.x, to.y - from.y)
            let isH  = abs(from.y - to.y) < 1
            
            let segmentVariant: TileVariant = isH ? .straightH : .straightV
            
            if i == 0 {
                addTile(at: from, variant: segmentVariant, to: scene)
            } else {
                let corner = detectCorner(
                    prev:    waypoints[i - 1],
                    current: from,
                    next:    to
                )
                addTile(at: from, variant: corner, to: scene)
            }
            
            let dx = (to.x - from.x) / dist
            let dy = (to.y - from.y) / dist
            var traveled: CGFloat = tileSize
            
            while traveled < dist - tileSize * 0.5 {
                let pos = CGPoint(
                    x: from.x + dx * traveled,
                    y: from.y + dy * traveled
                )
                addTile(at: pos, variant: segmentVariant, to: scene)
                traveled += tileSize
            }
        }
        
        if let last = waypoints.last {
            addTile(at: last, variant: .straightV, to: scene)
        }
    }
    
    private func addTile(at pos: CGPoint, variant: TileVariant, to scene: SKScene) {
        let sz = CGSize(width: tileSize - 2, height: tileSize - 2)
        let bg = SKShapeNode(rectOf: sz, cornerRadius: 4)
        
        switch variant {
        case .straightH, .straightV:
            bg.fillColor = UIColor(red: 0.45, green: 0.32, blue: 0.18, alpha: 1)
        case .cornerTR, .cornerTL, .cornerBR, .cornerBL:
            bg.fillColor = UIColor(red: 0.35, green: 0.22, blue: 0.10, alpha: 1)
        }
        
        bg.strokeColor = UIColor.black.withAlphaComponent(0.35)
        bg.lineWidth   = 1
        bg.position    = pos
        bg.zPosition   = 0
        scene.addChild(bg)
    }
    
    private func detectCorner(prev: CGPoint, current: CGPoint, next: CGPoint) -> TileVariant {
        let fromBelow = prev.y < current.y - 1
        let fromAbove = prev.y > current.y + 1
        let fromLeft  = prev.x < current.x - 1
        let fromRight = prev.x > current.x + 1
        let goRight   = next.x > current.x + 1
        let goLeft    = next.x < current.x - 1
        let goUp      = next.y > current.y + 1
        let goDown    = next.y < current.y - 1
        
        switch true {
        case (fromBelow && goRight) || (fromLeft  && goUp):   return .cornerTR
        case (fromBelow && goLeft)  || (fromRight && goUp):   return .cornerTL
        case (fromAbove && goRight) || (fromLeft  && goDown): return .cornerBR
        case (fromAbove && goLeft)  || (fromRight && goDown): return .cornerBL
        default: return .cornerBR
        }
    }
}
