//
//  PathComponent.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathComponent: GKComponent {
    let waypoints: [CGPoint]
    let halfWidth: CGFloat

    init(waypoints: [CGPoint], halfWidth: CGFloat) {
        self.waypoints = waypoints
        self.halfWidth = halfWidth
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func distance(to point: CGPoint) -> CGFloat {
        guard waypoints.count >= 2 else { return .greatestFiniteMagnitude }
        var best = CGFloat.greatestFiniteMagnitude
        for i in 0..<waypoints.count - 1 {
            let d = Self.pointToSegment(point, waypoints[i], waypoints[i + 1])
            if d < best { best = d }
        }
        return best
    }

    func nearestSegmentIndex(to point: CGPoint) -> Int {
        guard waypoints.count >= 2 else { return 0 }
        var best = CGFloat.greatestFiniteMagnitude
        var idx = 0
        for i in 0..<waypoints.count - 1 {
            let d = Self.pointToSegment(point, waypoints[i], waypoints[i + 1])
            if d < best { best = d; idx = i }
        }
        return idx
    }

    func backward(from point: CGPoint) -> [CGPoint] {
        let nearest = nearestSegmentIndex(to: point)
        var result: [CGPoint] = [point]
        for i in stride(from: nearest, through: 0, by: -1) {
            result.append(waypoints[i])
        }
        return result
    }

    private static func pointToSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
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
}
