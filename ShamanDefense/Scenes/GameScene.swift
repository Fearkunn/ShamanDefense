//
//  GameScene.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {

    private let tileSize: CGFloat = 36
    private let minPlacementSpacing: CGFloat = GhostMetrics.diameter
    private var pathManager: PathManager!
    private(set) var waveManager: WaveManager!

    private(set) var registry: EntityRegistry!
    private var lastUpdateTime: TimeInterval = 0

    let humansLayer = SKNode()
    let towersLayer = SKNode()
    let trapsLayer = SKNode()
    let projectilesLayer = SKNode()
    let fxLayer = SKNode()

    private func tooCloseToExisting(_ point: CGPoint) -> Bool {
        for child in children {
            guard let ghost = child as? GhostNode else { continue }
            if hypot(ghost.position.x - point.x, ghost.position.y - point.y) < minPlacementSpacing {
                return true
            }
        }
        return false
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.13, green: 0.11, blue: 0.16, alpha: 1)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0, y: 0)

        humansLayer.zPosition = 2
        towersLayer.zPosition = 1
        trapsLayer.zPosition = 1
        projectilesLayer.zPosition = 5
        fxLayer.zPosition = 4
        addChild(humansLayer)
        addChild(towersLayer)
        addChild(trapsLayer)
        addChild(projectilesLayer)
        addChild(fxLayer)

        let pathFollowSystem      = GKComponentSystem<GKComponent>(componentClass: PathFollowComponent.self)
        let stateMachineSystem    = GKComponentSystem<GKComponent>(componentClass: StateMachineComponent.self)
        registry = EntityRegistry(systems: [
            pathFollowSystem,
            stateMachineSystem,
        ])

        pathManager = PathManager(scene: self, tileSize: tileSize)
        pathManager.setup()

        waveManager = WaveManager(scene: self, waypoints: pathManager.waypoints, tileSize: tileSize)
        waveManager.start()
    }

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 0
        } else {
            dt = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime
        registry?.update(deltaTime: dt)
    }

    func spawnHuman() {
        guard let pathManager else { return }
        let entity = EntityFactory.makeHuman(waypoints: pathManager.waypoints)
        if let pf = entity.component(ofType: PathFollowComponent.self) {
            pf.onArrive = { [weak self, weak entity] in
                guard let self, let entity else { return }
                self.removeEntity(entity)
            }
        }
        if let health = entity.component(ofType: HealthComponent.self),
           let sprite = entity.component(ofType: SpriteComponent.self) {
            health.onDeath = { [weak self, weak entity] in
                guard let self, let entity else { return }
                let node = sprite.node
                node.removeAllActions()
                node.run(.sequence([.fadeOut(withDuration: 0.15), .removeFromParent()]))
                self.removeEntity(entity)
            }
        }
        installEntity(entity, in: humansLayer)
    }

    func installEntity(_ entity: GameEntity, in layer: SKNode) {
        if let node = entity.component(ofType: SpriteComponent.self)?.node {
            layer.addChild(node)
        }
        registry.add(entity)
    }

    func removeEntity(_ entity: GameEntity) {
        registry.remove(entity)
        if let node = entity.component(ofType: SpriteComponent.self)?.node, node.parent != nil {
            node.removeFromParent()
        }
    }

    func canPlace(_ character: CharacterData, at scenePoint: CGPoint) -> Bool {
        if tooCloseToExisting(scenePoint) { return false }
        guard let pathManager else { return false }
        let dist = pathManager.distanceToPath(scenePoint)
        let ghostRadius = GhostMetrics.diameter / 2
        let pathHalf = pathManager.pathHalfWidth
        switch character.kind {
        case .tower: return dist > ghostRadius + pathHalf
        case .trap:  return dist + ghostRadius <= pathHalf
        }
    }

    func place(_ character: CharacterData, at scenePoint: CGPoint) {
        guard canPlace(character, at: scenePoint) else { return }
        let node = Self.makeNode(for: character)
        node.position = scenePoint
        addChild(node)
        if let trap = node as? TrapNode {
            trap.pathWaypoints = pathManager.waypoints
            trap.arm()
        }
    }

    static func makeNode(for character: CharacterData) -> GhostNode {
        switch character.id {
        case .keti:   return KetiNode()
        case .poci:   return PociNode()
        case .gugun:  return GugunNode()
        case .yayang: return YayangNode()
        case .yuyul:  return YuyulNode()
        }
    }
}
