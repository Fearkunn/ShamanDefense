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

    private(set) var registry: EntityRegistry!
    private var lastUpdateTime: TimeInterval = 0
    private var pendingRemovals: [GameEntity] = []

    let mapLayer = SKNode()
    let humansLayer = SKNode()
    let towersLayer = SKNode()
    let trapsLayer = SKNode()
    let projectilesLayer = SKNode()
    let fxLayer = SKNode()
    let hudLayer = SKNode()

    private var scoreLabel: SKLabelNode!
    private var gameOverNode: GameOverNode?
    private var spawnerEntity: SpawnerEntity?
    private(set) var isGameOver = false

    private func tooCloseToExisting(_ point: CGPoint) -> Bool {
        for entity in registry.all {
            guard let blocker = entity.component(ofType: PlacementBlockerComponent.self),
                  let pos = entity.component(ofType: SpriteComponent.self)?.position else { continue }
            if hypot(pos.x - point.x, pos.y - point.y) < blocker.radius + minPlacementSpacing / 2 {
                return true
            }
        }
        return false
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.13, green: 0.11, blue: 0.16, alpha: 1)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0, y: 0)

        mapLayer.zPosition = 0
        humansLayer.zPosition = 2
        towersLayer.zPosition = 1
        trapsLayer.zPosition = 1
        projectilesLayer.zPosition = 5
        fxLayer.zPosition = 4
        hudLayer.zPosition = 50
        addChild(mapLayer)
        addChild(humansLayer)
        addChild(towersLayer)
        addChild(trapsLayer)
        addChild(projectilesLayer)
        addChild(fxLayer)
        addChild(hudLayer)

        registry = EntityRegistry(systems: [
            EffectsSystem(),
            PathFollowSystem(),
            SpawnerSystem(),
            HomingSystem(),
            LifetimeSystem(),
            ProximityTriggerSystem(),
            PathRunnerSystem(),
            SlowAuraSystem(),
            StateMachineSystem(),
        ])

        loadMap()
        registry.add(ScoreEntity())
        buildScoreLabel()

        let spawner = SpawnerEntity(interval: 3) { [weak self] in
            self?.spawnHuman()
        }
        spawnerEntity = spawner
        registry.add(spawner)
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
        flushPendingRemovals()
    }

    private func flushPendingRemovals() {
        guard !pendingRemovals.isEmpty else { return }
        let batch = pendingRemovals
        pendingRemovals.removeAll(keepingCapacity: true)
        for entity in batch {
            registry.remove(entity)
            if let node = entity.component(ofType: SpriteComponent.self)?.node, node.parent != nil {
                node.removeFromParent()
            }
        }
    }

    // MARK: - Spawn / install

    func spawnHuman() {
        guard let path = registry.path else { return }
        let entity = HumanEntity(waypoints: path.waypoints)
        if let pf = entity.component(ofType: PathFollowComponent.self) {
            pf.onArrive = { [weak self, weak entity] in
                guard let self, let entity else { return }
                self.removeEntity(entity)
                self.humanReachedFinish()
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
                self.humanDefeated()
            }
        }
        installEntity(entity, in: humansLayer)
    }

    // MARK: - Score / game over

    private func buildScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 52)
        hudLayer.addChild(scoreLabel)
    }

    func humanDefeated() {
        guard !isGameOver, let score = registry.score else { return }
        score.add(1)
        scoreLabel.text = "\(score.current)"
        scoreLabel.removeAction(forKey: "pop")
        scoreLabel.run(.sequence([
            .scale(to: 1.35, duration: 0.08),
            .scale(to: 1.00, duration: 0.08)
        ]), withKey: "pop")
    }

    func humanReachedFinish() {
        guard !isGameOver, let score = registry.score else { return }
        isGameOver = true
        if let spawner = spawnerEntity {
            removeEntity(spawner)
            spawnerEntity = nil
        }
        let wasFirstPlay = score.isFirstPlay
        score.saveAndFinalize()

        let overlay = GameOverNode(score: score.current,
                                   highScore: score.high,
                                   isFirstPlay: wasFirstPlay,
                                   sceneSize: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        addChild(overlay)
        gameOverNode = overlay

        overlay.onRetry    = { [weak self] in self?.restartGame() }
        overlay.onMainMenu = { [weak self] in self?.goToMainMenu() }
    }

    private func restartGame() {
        gameOverNode = nil
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        view?.presentScene(newScene, transition: .fade(withDuration: 0.4))
    }

    private func goToMainMenu() {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        if let overlay = gameOverNode {
            overlay.handleTap(at: loc)
        }
    }

    func spawnTower(_ character: CharacterData, at point: CGPoint) {
        let entity = TowerEntity(character: character)
        entity.component(ofType: SpriteComponent.self)?.position = point
        installEntity(entity, in: towersLayer)
    }

    func spawnProjectile(from origin: CGPoint,
                         target: GameEntity,
                         launcher: ProjectileLauncherComponent) {
        let entity = ProjectileEntity(from: origin, target: target, launcher: launcher)

        if let homing = entity.component(ofType: HomingComponent.self) {
            homing.onImpact = { [weak self, weak entity] point, target in
                guard let self, let entity else { return }
                if let damage = entity.component(ofType: DamageOnHitComponent.self) {
                    if let aoe = damage.aoeRadius {
                        self.applyAoEDamage(at: point, radius: aoe, amount: damage.damage, color: damage.color)
                    } else if let target,
                              let health = target.component(ofType: HealthComponent.self) {
                        health.takeDamage(damage.damage)
                    }
                }
                self.removeEntity(entity)
            }
            homing.onTargetLost = { [weak self, weak entity] in
                guard let self, let entity else { return }
                self.removeEntity(entity)
            }
        }
        if let lifetime = entity.component(ofType: LifetimeComponent.self) {
            lifetime.onExpire = { [weak self, weak entity] in
                guard let self, let entity else { return }
                self.removeEntity(entity)
            }
        }

        installEntity(entity, in: projectilesLayer)
    }

    func applyAoEDamage(at point: CGPoint, radius: CGFloat, amount: CGFloat, color: SKColor) {
        let flash = SKShapeNode(circleOfRadius: radius)
        flash.position = point
        flash.fillColor = color.withAlphaComponent(0.35)
        flash.strokeColor = color
        flash.lineWidth = 2
        fxLayer.addChild(flash)
        flash.run(.sequence([
            .group([.fadeOut(withDuration: 0.25), .scale(to: 1.2, duration: 0.25)]),
            .removeFromParent()
        ]))

        for human in registry.humans {
            guard let pos = human.component(ofType: SpriteComponent.self)?.position,
                  let health = human.component(ofType: HealthComponent.self), health.isAlive else { continue }
            if hypot(pos.x - point.x, pos.y - point.y) <= radius {
                health.takeDamage(amount)
            }
        }
    }

    func installEntity(_ entity: GameEntity, in layer: SKNode) {
        if let node = entity.component(ofType: SpriteComponent.self)?.node {
            layer.addChild(node)
        }
        registry.add(entity)
    }

    func removeEntity(_ entity: GameEntity) {
        pendingRemovals.append(entity)
    }

    // MARK: - Placement

    func pathBackward(from point: CGPoint) -> [CGPoint] {
        registry.path?.backward(from: point) ?? [point]
    }

    func canPlace(_ character: CharacterData, at scenePoint: CGPoint) -> Bool {
        if tooCloseToExisting(scenePoint) { return false }
        guard let path = registry.path else { return false }
        let dist = path.distance(to: scenePoint)
        let ghostRadius = GhostMetrics.diameter / 2
        let pathHalf = path.halfWidth
        switch character.kind {
        case .tower: return dist > ghostRadius + pathHalf
        case .trap:  return dist + ghostRadius <= pathHalf
        }
    }

    func place(_ character: CharacterData, at scenePoint: CGPoint) {
        guard canPlace(character, at: scenePoint) else { return }
        switch character.kind {
        case .tower: spawnTower(character, at: scenePoint)
        case .trap:  spawnTrap(character, at: scenePoint)
        }
    }

    // MARK: - Map loading

    private func loadMap() {
        var wpNodes: [SKNode] = []
        if let ref = SKReferenceNode(fileNamed: "Map") {
            let authored = SKScene(fileNamed: "Map")?.size ?? size
            let scale = min(size.width / authored.width, size.height / authored.height)
            ref.setScale(scale)
            ref.position = CGPoint(x: size.width / 2, y: size.height / 2)
            mapLayer.addChild(ref)
            collectWaypointNodes(in: ref, into: &wpNodes)
        }
        wpNodes.sort { ($0.name ?? "") < ($1.name ?? "") }
        guard wpNodes.count >= 2 else {
            assertionFailure("Map.sks must contain at least 2 wp_* nodes")
            return
        }
        let points = wpNodes.map { node -> CGPoint in
            guard let parent = node.parent else { return node.position }
            return convert(node.position, from: parent)
        }
        wpNodes.forEach { node in
            if !(node is SKSpriteNode) { node.isHidden = true }
        }
        registry.add(PathEntity(waypoints: points, halfWidth: tileSize / 2))
    }

    private func collectWaypointNodes(in root: SKNode, into out: inout [SKNode]) {
        for child in root.children {
            if let name = child.name, name.hasPrefix("wp_") {
                out.append(child)
            }
            if !child.children.isEmpty {
                collectWaypointNodes(in: child, into: &out)
            }
        }
    }

    func spawnTrap(_ character: CharacterData, at point: CGPoint) {
        guard let path = registry.path else { return }
        let entity = TrapEntity(character: character, pathWaypoints: path.waypoints)
        entity.component(ofType: SpriteComponent.self)?.position = point

        if let trigger = entity.component(ofType: ProximityTriggerComponent.self) {
            trigger.onTrigger = { [weak entity] _ in
                guard let entity,
                      let sm = entity.component(ofType: StateMachineComponent.self) else { return }
                switch character.id {
                case .yayang: sm.stateMachine.enter(YayangTriggeredState.self)
                case .yuyul:  sm.stateMachine.enter(YuyulTriggeredState.self)
                default: break
                }
            }
        }
        installEntity(entity, in: trapsLayer)
    }
}
