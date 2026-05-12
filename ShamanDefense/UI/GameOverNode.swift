//
//  GameOverNode.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 12/05/26.
//

import SpriteKit

class GameOverNode: SKNode {
    
    var onRetry:    (() -> Void)?
    var onMainMenu: (() -> Void)?
    
    init(score: Int, highScore: Int, isFirstPlay: Bool, sceneSize: CGSize) {
        super.init()
        buildUI(score: score,
                highScore: highScore,
                isFirstPlay: isFirstPlay,
                sceneSize: sceneSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func buildUI(score: Int, highScore: Int, isFirstPlay: Bool, sceneSize: CGSize) {
        let dim = SKShapeNode(rectOf: sceneSize)
        dim.fillColor = UIColor.black.withAlphaComponent(0.55)
        dim.strokeColor = .clear
        dim.zPosition = 0
        addChild(dim)
        
        let cardSize = CGSize(width: sceneSize.width * 0.78, height: 360)
        let card = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        card.fillColor = UIColor(white: 0.22, alpha: 0.95)
        card.strokeColor = .clear
        card.position = CGPoint(x: 0, y: 20)
        card.zPosition = 1
        addChild(card)
        
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "Game Over"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 105)
        titleLabel.zPosition = 2
        addChild(titleLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 52
        scoreLabel.fontColor = .white
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: 42)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        if !isFirstPlay {
            let hsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            hsLabel.text = "High Score: \(highScore)"
            hsLabel.fontSize = 17
            hsLabel.fontColor = UIColor(white: 0.70, alpha: 1)
            hsLabel.verticalAlignmentMode = .center
            hsLabel.horizontalAlignmentMode = .center
            hsLabel.position = CGPoint(x: 0, y: -5)
            hsLabel.zPosition = 2
            addChild(hsLabel)
        }
        
        card.addChild(makeButton(label: "Retry",
                            width: cardSize.width * 0.78,
                            height: 54,
                            color: UIColor(white: 0.35, alpha: 1),
                            name: "btnRetry",
                            y: -75))
        
        card.addChild(makeButton(label: "Main Menu",
                            width: cardSize.width * 0.6,
                            height: 46,
                            color: UIColor(white: 0.20, alpha: 1),
                            name: "btnMainMenu",
                            y: -135))
        
        alpha = 0
        setScale(0.88)
        run(.group([
            .fadeIn(withDuration: 0.25),
            .scale(to: 1.0, duration: 0.25)
        ]))
    }
    
    func handleTap(at location: CGPoint) {
        let localPoint = convert(location, from: parent!)
        for node in nodes (at: localPoint) {
            switch node.name {
            case "btnRetry": onRetry?()
            case "btnMainMenu": onMainMenu?()
            default: break
            }
        }
    }
    
    private func makeButton(label: String, width: CGFloat,height: CGFloat, color: UIColor, name: String, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = CGPoint(x: 0, y: y)
        container.zPosition = 2
        
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        bg.fillColor = color
        bg.strokeColor = .clear
        bg.name = name
        container.addChild(bg)
        
        let lbl = SKLabelNode(fontNamed: "Helvetica-Bold")
        lbl.text = label
        lbl.fontSize = 18
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        lbl.name = name
        container.addChild(lbl)
        
        return container
    }
}
