//
//  GameScene.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit

final class GameScene: SKScene {
    
    private let tileSize: CGFloat = 36
    private let minPlacementSpacing: CGFloat = GhostMetrics.diameter
    private var pathManager: PathManager!
    private var waveManager: WaveManager!
    private var scoreManager: ScoreManager!
    private var scoreLabel: SKLabelNode!
    private var gameOverNode: GameOverNode?
    private var isGameOver = false
    var onRestart: (() -> Void)?
    
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
        
        pathManager = PathManager(scene: self, tileSize: tileSize)
        pathManager.setup()
        
        waveManager = WaveManager(scene: self, waypoints: pathManager.waypoints, tileSize: tileSize)
        waveManager.start()
        
        scoreManager = ScoreManager()
        buildScoreLabel()
    }
    
    private func buildScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 52)
        scoreLabel.zPosition = 50
        addChild(scoreLabel)
    }
    
    func humanDefeated() {
        guard !isGameOver else { return }
        scoreManager.addScore(1)
        scoreLabel.text = "\(scoreManager.currentScore)"
        scoreLabel.removeAction(forKey: "pop")
        scoreLabel.run(.sequence([
            .scale(to: 1.35, duration: 0.08),
            .scale(to: 1.00, duration: 0.08)
        ]), withKey: "pop")
    }
    
    func humanReachedFinish() {
        guard !isGameOver else { return }
        isGameOver = true
        waveManager.stop()
        let wasFirstPlay = scoreManager.isFirstPlay
        scoreManager.saveAndFinalize()
        
        let overlay = GameOverNode(
            score: scoreManager.currentScore,
            highScore: scoreManager.highScore,
            isFirstPlay: wasFirstPlay,
            sceneSize: size
        )
        
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
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
            return
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
