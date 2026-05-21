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
    
    private let baseTileSize: CGFloat = 80
    private let spriteTileMultiplier: CGFloat = 3
    private var tileSize: CGFloat = 80
    
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
    
    var scoreLabel: GameLabelNode!
    private var shamanHUD: ShamanHUD?
    private var waveManagerEntity: WaveManagerEntity?
    private(set) var isGameOver = false

    var onIntermission: ((Int) -> Void)?
    var onWaveStart: ((Int) -> Void)?
    var onRetry: (() -> Void)?
    var onMainMenu: (() -> Void)?
    var onGameOver: ((_ score: Int, _ highScore: Int, _ isFirstPlay: Bool) -> Void)?
    var onSpiritChanged: ((Int) -> Void)?

    private var currentSpirit: Int = 10
    private var hasPlayedWaveSpawnSound = false

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
    
    
    private func towerTooCloseToExisting(_ foot: TowerFoot) -> Bool {
        for entity in registry.towers {
            guard let pos = entity.component(ofType: SpriteComponent.self)?.position else { continue }
            if foot.overlaps(TowerPlacement.foot(at: pos)) {
                return true
            }
        }
        return false
    }

    func dragIndicatorRadius(for kind: EntityKind) -> CGFloat {
        switch kind {
        case .tower: return TowerPlacement.radius
        case .trap:  return TrapPlacement.visualRadius
        }
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
        
        configureWaveManager()
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
    
    // MARK: - Wave manager
    
    private func configureWaveManager() {
        let waveManager = WaveManagerEntity()
        if let mgr = waveManager.component(ofType: WaveManagerComponent.self) {
            mgr.onSpawn = { [weak self] archetype, hpMult in
                guard let self else { return }
                
                if !self.hasPlayedWaveSpawnSound {
                    SoundManager.shared.playSFX(
                        "human_spawn.wav",
                        on: self
                    )
                    
                    self.hasPlayedWaveSpawnSound = true
                }
                
                self.spawnHuman(
                    archetype: archetype,
                    hpMultiplier: hpMult
                )
            }
            
            mgr.onWaveStart = { [weak self] wave in
                guard let self else { return }
                
                self.hasPlayedWaveSpawnSound = false
                self.onWaveStart?(wave)
            }
            
            mgr.onIntermission = { [weak self] nextWave in
                guard let self else { return }
                
                SoundManager.shared.playSFX(
                    "wave.wav",
                    on: self
                )
                
                self.onIntermission?(nextWave)
            }
            
            mgr.humansAliveCount = { [weak self] in
                self?.registry.humans.count ?? 0
            }
            
            SoundManager.shared.playSFX(
                "wave.wav",
                on: self
            )

            onIntermission?(1)
        }
        waveManagerEntity = waveManager
        registry.add(waveManager)
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
        if let health = entity.component(ofType: HealthComponent.self) {
            health.onDeath = { [weak self, weak entity] in
                guard let self, let entity else { return }
                
                SoundManager.shared.playSFX(
                    "human_dead.wav",
                    on: self
                )
                
                entity.playDeathAnimation { [weak self, weak entity] in
                    guard let self, let entity else { return }
                    self.removeEntity(entity)
                    self.humanDefeated()
                }
            }
        }
        installEntity(entity, in: humansLayer)
    }
    
    // MARK: - Score / game over
    
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
        
        SoundManager.shared.playSFX(
            "game_over.wav",
            on: self
        )
        
        HapticManager.shared.notification(.error)
        
        if let waveManager = waveManagerEntity {
            waveManager.component(ofType: WaveManagerComponent.self)?.stop()
            removeEntity(waveManager)
            waveManagerEntity = nil
        }
        let wasFirstPlay = score.isFirstPlay
        score.saveAndFinalize()

        onGameOver?(score.current, score.high, wasFirstPlay)
    }

    func restartGame() {
        resetWorld()
        onRetry?()
    }

    func goToMainMenu() {
        onMainMenu?()
    }

    private func resetWorld() {
        for entity in registry.all where entity.archetype == .human
                                       || entity.archetype == .tower
                                       || entity.archetype == .trap
                                       || entity.archetype == .projectile {
            if let node = entity.component(ofType: SpriteComponent.self)?.node {
                node.removeFromParent()
            }
            registry.remove(entity)
        }
        if let scoreEntity = registry.all.first(where: { $0 is ScoreEntity }) {
            registry.remove(scoreEntity)
        }
        if let waveManager = waveManagerEntity {
            waveManager.component(ofType: WaveManagerComponent.self)?.stop()
            registry.remove(waveManager)
        }
        waveManagerEntity = nil

        pendingRemovals.removeAll(keepingCapacity: true)
        fxLayer.removeAllChildren()
        humansLayer.removeAllChildren()
        towersLayer.removeAllChildren()
        trapsLayer.removeAllChildren()
        projectilesLayer.removeAllChildren()
        removeAllActions()

        registry.pause?.isPaused = false
        isGameOver = false
        lastUpdateTime = 0
        currentSpirit = 10
        updateSpirit(currentSpirit)

        registry.add(ScoreEntity())
        scoreLabel?.removeAllActions()
        scoreLabel?.text = "0"

        configureWaveManager()
    }

    func spawnTower(_ character: CharacterData, at point: CGPoint) {
        let entity = TowerEntity(character: character)
        entity.component(ofType: SpriteComponent.self)?.position = point
        installEntity(entity, in: towersLayer)
    }
    
    func spawnProjectile(source: GameEntity,
                         from origin: CGPoint,
                         target: GameEntity,
                         launcher: ProjectileLauncherComponent,
                         style: GhostAttackStyle = .projectile) {
        let context = GhostAttackContext(
            scene: self,
            source: source,
            origin: origin,
            target: target,
            launcher: launcher
        )
        if GhostAttackDispatcher.executeSpecialIfNeeded(style: style, context: context) {
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
                        self.playHumanHitFlash(on: target, color: damage.color)
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
        applyAoEDamage(at: point, radius: radius, amount: amount, color: color, showsFlash: true)
    }

    func applyAoEDamage(at point: CGPoint, radius: CGFloat, amount: CGFloat, color: SKColor, showsFlash: Bool) {
        if showsFlash {
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
        }

        for human in registry.humans {
            guard let pos = human.component(ofType: SpriteComponent.self)?.position,
                  let health = human.component(ofType: HealthComponent.self), health.isAlive else { continue }
            if hypot(pos.x - point.x, pos.y - point.y) <= radius {
                playHumanHitFlash(on: human, color: color)
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
        guard let path = registry.path else { return false }
        switch character.kind {
        case .tower:
            let foot = TowerPlacement.foot(at: scenePoint)
            if towerTooCloseToExisting(foot) { return false }
            return !path.tileRects.contains { foot.overlaps(tile: $0) }
        case .trap:
            return path.distance(to: scenePoint) <= TrapPlacement.pathTolerance
        }
    }
    
    @discardableResult
    func place(_ character: CharacterData, at scenePoint: CGPoint) -> Bool {
        guard canPlace(character, at: scenePoint) else {
            SoundManager.shared.playSFX(
                "wrong_placement.wav",
                on: self
            )
            return false
        }
        
        guard spendSpirit(character.cost) else {
            SoundManager.shared.playSFX(
                "wrong_placement.wav",
                on: self
            )
            return false
        }
        
        SoundManager.shared.playSFX(
            "placement.wav",
            on: self
        )
        
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
        var tileRects: [CGRect] = []
        if let ref = mapLayer.children.first {
            collectTileRects(in: ref, authoredLogical: baseTileSize, into: &tileRects)
        }
        registry.add(PathEntity(waypoints: points, tileRects: tileRects))
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
    
    private func collectTileRects(in root: SKNode, authoredLogical: CGFloat, into out: inout [CGRect]) {
        for child in root.children {
            if let sprite = child as? SKSpriteNode {
                let minDim = min(sprite.size.width, sprite.size.height)
                let maxDim = max(sprite.size.width, sprite.size.height)
                if abs(minDim - authoredLogical) < 1.0, abs(maxDim - authoredLogical) < 1.0 {
                    let c = convert(sprite.position, from: sprite.parent ?? root)
                    out.append(CGRect(x: c.x - tileSize / 2, y: c.y - tileSize / 2,
                                      width: tileSize, height: tileSize))
                }
            }
            if !child.children.isEmpty {
                collectTileRects(in: child, authoredLogical: authoredLogical, into: &out)
            }
        }
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
                case .yayang:
                    SoundManager.shared.playSFX(
                        "yayang_attack.wav",
                        on: self
                    )
                    self.playYayangPlacementSequence(entity)
                    
                case .yuyul:
                    SoundManager.shared.playSFX(
                        "yuyul_attack.wav",
                        on: self
                    )
                    sm.stateMachine.enter(
                        YuyulTriggeredState.self
                    )
                default: break
                }
            }
        }
        installEntity(entity, in: trapsLayer)
    }

    private func playYayangPlacementSequence(_ entity: TrapEntity) {
        guard let root = entity.component(ofType: SpriteComponent.self)?.node,
              let trigger = entity.component(ofType: ProximityTriggerComponent.self),
              let stateMachine = entity.component(ofType: StateMachineComponent.self) else { return }

        trigger.armed = false
        root.removeAction(forKey: "yayang_placement_sequence")
        let originalZPosition = root.zPosition
        let worldPosition = root.parent?.convert(root.position, to: self) ?? root.position
        root.removeFromParent()
        root.position = hudLayer.convert(worldPosition, from: self)
        root.zPosition = 60
        hudLayer.addChild(root)

        let dimOverlay = SKShapeNode(rectOf: size)
        dimOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dimOverlay.fillColor = .black
        dimOverlay.strokeColor = .clear
        dimOverlay.alpha = 0
        dimOverlay.zPosition = 49
        hudLayer.addChild(dimOverlay)
        dimOverlay.run(.fadeAlpha(to: 0.35, duration: 0.25))

        let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        let sequence = SKAction.sequence([
            .wait(forDuration: 0.70),
            .group([
                .move(to: centerPoint, duration: 0.45),
                .scale(to: 1.35, duration: 0.45)
            ]),
            .wait(forDuration: 0.10),
            .run { [weak self, weak stateMachine, weak dimOverlay, weak root] in
                stateMachine?.stateMachine.enter(YayangTriggeredState.self)
                self?.run(.sequence([
                    .wait(forDuration: 0.05),
                    .run { [weak self] in
                        guard let self else { return }
                        root?.zPosition = originalZPosition
                        if let root,
                           let worldBack = root.parent?.convert(root.position, to: self) {
                            root.removeFromParent()
                            root.position = self.trapsLayer.convert(worldBack, from: self)
                            self.trapsLayer.addChild(root)
                        }
                        dimOverlay?.run(.sequence([
                            .fadeOut(withDuration: 0.35),
                            .removeFromParent()
                        ]))
                    }
                ]))
            }
        ])
        sequence.timingMode = .easeInEaseOut
        root.run(sequence, withKey: "yayang_placement_sequence")
    }

    private func setupMapUI() {
        guard let path = registry.path else { return }
        let endPoint = path.waypoints.last ?? .zero
        let hud = ShamanHUD(anchor: endPoint)
        mapLayer.addChild(hud)
        shamanHUD = hud
    }

    func updateSpirit(_ value: Int) {
        shamanHUD?.updateSpirit(value)
        onSpiritChanged?(value)
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
