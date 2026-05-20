//
//  GameScene.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit
import GameplayKit
import UIKit

final class GameScene: SKScene {
    
    private let baseTileSize: CGFloat = 36
    private let spriteTileMultiplier: CGFloat = 3
    private var tileSize: CGFloat = 36
    private let minPlacementSpacing: CGFloat = GhostMetrics.diameter
    
    private(set) var registry: EntityRegistry
    var pauseComponent: PauseComponent? { registry.pause }
    private var lastUpdateTime: TimeInterval = 0
    private var pendingRemovals: [GameEntity] = []
    
    let mapLayer = SKNode()
    let humansLayer = SKNode()
    let towersLayer = SKNode()
    let trapsLayer = SKNode()
    let projectilesLayer = SKNode()
    let fxLayer = SKNode()
    let hudLayer = SKNode()
    
    private var scoreLabel: GameLabelNode!
    private var spiritLabel: GameLabelNode?
    private var spiritCounterNode: SKSpriteNode?
    private var gameOverNode: GameOverNode?
    private var waveManagerEntity: WaveManagerEntity?
    private(set) var isGameOver = false

    var onIntermission: ((Int) -> Void)?
    var onWaveStart: ((Int) -> Void)?

    private var currentSpirit: Int = 6

    override init() {
        let heartbeatSystem = HeartbeatSystem()
        
        registry = EntityRegistry(systems: [
            EffectsSystem(),
            PathFollowSystem(),
            WaveSystem(),
            HomingSystem(),
            LifetimeSystem(),
            ProximityTriggerSystem(),
            PathRunnerSystem(),
            SlowAuraSystem(),
            StateMachineSystem(),
            heartbeatSystem
        ])
        registry.add(GameStateEntity())
        super.init(size: .zero)
        heartbeatSystem.scene = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    
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
        
        loadMap()
        setupMapUI()
        updateSpirit(currentSpirit)
        registry.add(ScoreEntity())
        buildScoreLabel()
        
        let waveManager = WaveManagerEntity()
        if let mgr = waveManager.component(ofType: WaveManagerComponent.self) {
            mgr.onSpawn = { [weak self] archetype, hpMult in
                self?.spawnHuman(archetype: archetype, hpMultiplier: hpMult)
            }
            mgr.onWaveStart = { [weak self] wave in
                self?.onWaveStart?(wave)
            }
            mgr.onIntermission = { [weak self] nextWave in
                self?.onIntermission?(nextWave)
            }
            mgr.humansAliveCount = { [weak self] in
                self?.registry.humans.count ?? 0
            }
            onIntermission?(1)
        }
        waveManagerEntity = waveManager
        registry.add(waveManager)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 0
        } else {
            dt = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime
        registry.update(deltaTime: dt)
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
    
    // MARK: - Spawn
    
    func spawnHuman(archetype: HumanArchetype = .blue, hpMultiplier: CGFloat = 1.0) {
        guard !isGameOver, let path = registry.path else { return }
        let entity = HumanEntity(waypoints: path.waypoints,
                                 archetype: archetype,
                                 hpMultiplier: hpMultiplier)
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
                
                if let pf = entity.component(ofType: PathFollowComponent.self) {
                    pf.frozen = true
                    pf.arrived = true
                }
                entity.component(ofType: SpriteAnimationComponent.self)?.stopAnimating()
                
                let node = sprite.node
                node.removeAllActions()
                let deathDuration: TimeInterval = 0.65
                
                if let body = node.children.first(where: { $0 is SKSpriteNode }) as? SKSpriteNode {
                    let deadTexture = SKTexture(imageNamed: "human_dead")
                    body.texture = deadTexture
                    body.size = CharacterSprites.size(for: deadTexture, height: CharacterSprites.spriteHeight)
                    body.removeAllActions()
                    body.alpha = 1
                    body.setScale(1.0)
                    body.run(
                        .group([
                            .moveBy(x: 0, y: 26, duration: deathDuration),
                            .fadeOut(withDuration: deathDuration),
                            .scale(to: 1.08, duration: deathDuration)
                        ])
                    )
                }
                
                self.run(
                    .sequence([
                        .wait(forDuration: deathDuration),
                        .run { [weak self, weak entity] in
                            guard let self, let entity else { return }
                            self.removeEntity(entity)
                            self.humanDefeated()
                        }
                    ])
                )
            }
        }
        installEntity(entity, in: humansLayer)
    }
    
    // MARK: - Score / game over
    
    private func buildScoreLabel() {
        
        let hangingBoard = SKSpriteNode(imageNamed: "hanging_score")
        hangingBoard.zPosition = 100
        hangingBoard.size = CGSize(width: 200, height: 100)
        
        hangingBoard.position = CGPoint(
            x: size.width / 2,
            y: size.height - 40
        )
        hudLayer.addChild(hangingBoard)
        
        let titleLabel = GameLabelNode(
            text: "Score:",
            fontSize: 10
        )
        titleLabel.position = CGPoint(
            x: 0,
            y: -2
        )
        titleLabel.zPosition = 101
        hangingBoard.addChild(titleLabel)
        
        scoreLabel = GameLabelNode(
            text: "0",
            fontSize: 40
        )
        
        scoreLabel.position = CGPoint(
            x: 0,
            y: -25
        )
        scoreLabel.zPosition = 101
        hangingBoard.addChild(scoreLabel)
    }
    
    func humanDefeated() {
        guard !isGameOver, let score = registry.score else { return }
        score.add(1)
        addSpirit(1)
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
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        
        if let waveManager = waveManagerEntity {
            waveManager.component(ofType: WaveManagerComponent.self)?.state = .stopped
            removeEntity(waveManager)
            waveManagerEntity = nil
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
        let newScene = GameScene()
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
        if launcher.sourceGhostID == .keti {
            guard let targetSprite = target.component(ofType: SpriteComponent.self),
                  let health = target.component(ofType: HealthComponent.self),
                  health.isAlive else { return }
            let targetPos = targetSprite.position
            let dx = targetPos.x - origin.x
            let dy = targetPos.y - origin.y
            let dist = max(hypot(dx, dy), 1)
            let dirX = dx / dist
            let dirY = dy / dist
            
            // Serangan Keti's Effect
            let mouthForward: CGFloat = CharacterSprites.spriteHeight * 0.62
            let mouthOrigin = CGPoint(
                x: origin.x + dirX * mouthForward,
                y: origin.y + dirY * mouthForward
            )
            let waveDuration: TimeInterval = 0.60
            let hitDelay: TimeInterval = 0.28
            for delay in [0.0, 0.05] {
                let wave = SKSpriteNode(imageNamed: "keti_effect")
                wave.size = CGSize(width: 24, height: 24)
                wave.position = mouthOrigin
                wave.zPosition = 12
                wave.alpha = 0.95
                wave.zRotation = atan2(dirY, dirX) + .pi
                fxLayer.addChild(wave)
                wave.run(.sequence([
                    .wait(forDuration: delay),
                    .group([
                        .move(to: targetPos, duration: waveDuration),
                        .scale(to: 1.45, duration: waveDuration),
                        .fadeOut(withDuration: waveDuration)
                    ]),
                    .removeFromParent()
                ]))
            }
            
            self.run(.sequence([
                .wait(forDuration: hitDelay),
                .run { [weak self, weak target, weak health] in
                    guard let self else { return }
                    if let aoe = launcher.aoeRadius {
                        self.applyAoEDamage(at: targetPos, radius: aoe, amount: launcher.damage, color: launcher.color)
                    } else if let health,
                              health.isAlive,
                              target?.component(ofType: SpriteComponent.self)?.node.parent != nil {
                        health.takeDamage(launcher.damage)
                    }
                }
            ]))
            return
        }
        
        // Serangan Poci's Headbutt
        if launcher.sourceGhostID == .poci {
            guard let targetSprite = target.component(ofType: SpriteComponent.self),
                  let health = target.component(ofType: HealthComponent.self),
                  health.isAlive else { return }
            
            let hit = SKSpriteNode(imageNamed: "poci_headbutt")
            hit.size = CGSize(width: 34, height: 34)
            hit.position = targetSprite.position
            hit.zPosition = 12
            hit.alpha = 1.0
            hit.setScale(0.75)
            fxLayer.addChild(hit)
            hit.run(.sequence([
                .group([
                    .moveBy(x: 0, y: 10, duration: 0.12),
                    .scale(to: 1.15, duration: 0.12),
                    .fadeAlpha(to: 0.85, duration: 0.12)
                ]),
                .group([
                    .moveBy(x: 0, y: 10, duration: 0.12),
                    .scale(to: 1.28, duration: 0.12),
                    .fadeOut(withDuration: 0.12)
                ]),
                .removeFromParent()
            ]))
            
            if let aoe = launcher.aoeRadius {
                applyAoEDamage(at: targetSprite.position, radius: aoe, amount: launcher.damage, color: launcher.color)
            } else {
                health.takeDamage(launcher.damage)
                playHeadbuttHitReaction(on: target)
            }
            return
        }
        
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
                        if damage.sourceGhostID == .poci {
                            self.playHeadbuttHitReaction(on: target)
                        }
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
    
    private func playHeadbuttHitReaction(on target: GameEntity) {
        guard let root = target.component(ofType: SpriteComponent.self)?.node,
              let body = root.children.first(where: { $0 is SKSpriteNode }) as? SKSpriteNode else { return }
        body.removeAction(forKey: "headbutt_hit")
        body.run(
            .sequence([
                .group([
                    .moveBy(x: 5, y: 1, duration: 0.05),
                    .rotate(byAngle: .pi / 18, duration: 0.05)
                ]),
                .group([
                    .moveBy(x: -7, y: -1, duration: 0.06),
                    .rotate(byAngle: -.pi / 12, duration: 0.06)
                ]),
                .group([
                    .moveTo(x: 0, duration: 0.04),
                    .moveTo(y: 0, duration: 0.04),
                    .rotate(toAngle: 0, duration: 0.04)
                ])
            ]),
            withKey: "headbutt_hit"
        )
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
        let towerPlacementDistance: CGFloat = 26
        let trapPlacementDistance: CGFloat = 5
        
        switch character.kind {
        case .tower:
            return dist > towerPlacementDistance
            
        case .trap:
            return dist <= trapPlacementDistance
        }
    }
    
    @discardableResult
    func place(_ character: CharacterData, at scenePoint: CGPoint) -> Bool {
        guard canPlace(character, at: scenePoint) else { return false }
        
        guard spendSpirit(character.cost) else {
            return false
        }
        
        switch character.kind {
        case .tower: spawnTower(character, at: scenePoint)
        case .trap:  spawnTrap(character, at: scenePoint)
        }
        
        return true
    }
    
    // MARK: - Map loading
    
    private func loadMap() {
        var wpNodes: [SKNode] = []
        let authoredScene = SKScene(fileNamed: "Map")
        if let ref = SKReferenceNode(fileNamed: "Map") {
            let authored = authoredScene?.size ?? size
            let scale = max(size.width / authored.width, size.height / authored.height)
            ref.setScale(scale)
            ref.position = CGPoint(x: size.width / 2, y: size.height / 2)
            mapLayer.addChild(ref)
            collectWaypointNodes(in: ref, into: &wpNodes)
            if let s = authoredScene { dumpNodes(s, depth: 0) }
            let localTile = authoredScene.flatMap { measureTileSize(in: $0) } ?? baseTileSize
            tileSize = localTile * scale
            CharacterSprites.renderHeight = tileSize * spriteTileMultiplier
            print("[GameScene] localTile=\(localTile) scale=\(scale) tileSize=\(tileSize) renderHeight=\(CharacterSprites.renderHeight)")
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
    
    private func findFirstTile(_ root: SKNode, median: CGFloat) -> SKSpriteNode? {
        for c in root.children {
            if let s = c as? SKSpriteNode, !(c.name ?? "").hasPrefix("wp_"),
               abs(min(s.size.width, s.size.height) - median) < 0.5 {
                return s
            }
            if let found = findFirstTile(c, median: median) { return found }
        }
        return nil
    }

    private func dumpNodes(_ n: SKNode, depth: Int) {
        let kind = String(describing: type(of: n))
        let sz: String = (n as? SKSpriteNode).map { "size=\($0.size)" } ?? ""
        print("\(String(repeating: "  ", count: depth))[\(kind)] name=\(n.name ?? "nil") \(sz)")
        for c in n.children { dumpNodes(c, depth: depth + 1) }
    }

    private func measureTileSize(in scene: SKScene) -> CGFloat? {
        var sizes: [CGFloat] = []
        func walk(_ n: SKNode) {
            if let s = n as? SKSpriteNode, !(n.name ?? "").hasPrefix("wp_") {
                sizes.append(min(s.size.width, s.size.height))
            }
            for c in n.children { walk(c) }
        }
        walk(scene)
        guard !sizes.isEmpty else { return nil }
        let sorted = sizes.sorted()
        let median = sorted[sorted.count / 2]
        guard let t = findFirstTile(scene, median: median) else { return nil }
        let half = CGPoint(x: t.size.width / 2, y: t.size.height / 2)
        let p0 = scene.convert(CGPoint(x: -half.x, y: -half.y), from: t)
        let p1 = scene.convert(half, from: t)
        return min(abs(p1.x - p0.x), abs(p1.y - p0.y))
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
    
    private func setupMapUI() {
        guard let path = registry.path else { return }
        let endPoint = path.waypoints.last ?? .zero
        let dukunOffset = CGPoint(x: 0, y: -20)
        let counterOffset = CGPoint(x: -5, y: -70)
        
        let dukun = SKSpriteNode(imageNamed: "shaman")
        dukun.setScale(0.8)
        dukun.position = CGPoint(
            x: endPoint.x + dukunOffset.x,
            y: endPoint.y + dukunOffset.y
        )
        dukun.zPosition = 10
        mapLayer.addChild(dukun)
        
        let float = SKAction.sequence([
            .moveBy(x: 0, y: 10, duration: 1),
            .moveBy(x: 0, y: -10, duration: 1)
        ])
        dukun.run(.repeatForever(float))
        
        let counter = SKSpriteNode(imageNamed: "spirit_counter")
        counter.size = CGSize(width: 110, height: 50)
        counter.position = CGPoint(
            x: endPoint.x + counterOffset.x,
            y: endPoint.y + counterOffset.y
        )
        counter.zPosition = 11
        mapLayer.addChild(counter)
        
        spiritCounterNode = counter
        
        let label = GameLabelNode(
            text: "0",
            fontSize: 20,
            color: .black
        )
        label.zPosition = 12
        label.position = CGPoint(x: 5, y: 3)
        
        counter.addChild(label)
        
        spiritLabel = label
    }
    
    func updateSpirit(_ value: Int) {
        spiritLabel?.text = "\(value)"
        
        spiritCounterNode?.run(.sequence([
            .scale(to: 1.15, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ]))
    }
    
    private func addSpirit(_ amount: Int) {
        currentSpirit += amount
        updateSpirit(currentSpirit)
    }
    
    @discardableResult
    private func spendSpirit(_ amount: Int) -> Bool {
        
        guard currentSpirit >= amount else {
            return false
        }
        
        currentSpirit -= amount
        updateSpirit(currentSpirit)
        
        return true
    }
    
}
