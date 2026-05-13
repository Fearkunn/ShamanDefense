//
//  PathFollowSystem.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class PathFollowSystem: ComponentSystem<PathFollowComponent> {

    override func add(_ entity: GameEntity) {
        super.add(entity)
        guard let pf = entity.component(ofType: PathFollowComponent.self),
              let sprite = entity.component(ofType: SpriteComponent.self),
              pf.waypoints.count >= 2 else { return }
        sprite.position = pf.waypoints[0]
        let target = pf.waypoints[1]
        faceSprite(entity, toward: target, from: pf.waypoints[0])
    }

    override func update(deltaTime: TimeInterval) {
        for pf in components {
            tick(pf, dt: deltaTime)
        }
    }

    private func tick(_ pf: PathFollowComponent, dt: TimeInterval) {
        guard !pf.arrived, !pf.frozen,
              let entity = pf.entity as? GameEntity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              pf.segmentIndex + 1 < pf.waypoints.count else { return }

        var step = pf.baseSpeed * pf.speedMultiplier * CGFloat(dt)
        var pos = sprite.position

        while step > 0 && pf.segmentIndex + 1 < pf.waypoints.count {
            let next = pf.waypoints[pf.segmentIndex + 1]
            let dx = next.x - pos.x
            let dy = next.y - pos.y
            let dist = hypot(dx, dy)
            if step >= dist {
                pos = next
                step -= dist
                pf.segmentIndex += 1
                if pf.segmentIndex + 1 < pf.waypoints.count {
                    faceSprite(entity, toward: pf.waypoints[pf.segmentIndex + 1], from: pos)
                }
            } else {
                pos.x += dx / dist * step
                pos.y += dy / dist * step
                step = 0
            }
        }
        sprite.position = pos

        if pf.segmentIndex + 1 >= pf.waypoints.count {
            pf.arrived = true
            pf.onArrive?()
        }
    }

    private func faceSprite(_ entity: GameEntity, toward target: CGPoint, from origin: CGPoint) {
        guard let anim = entity.component(ofType: SpriteAnimationComponent.self) else { return }
        anim.face(dx: target.x - origin.x, dy: target.y - origin.y)
    }
}
