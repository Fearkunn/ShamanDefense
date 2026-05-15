//
//  GameOverNode.swift
//  ShamanDefense
//

import SpriteKit

final class GameOverNode: SKNode {

    var onRetry:    (() -> Void)?
    var onMainMenu: (() -> Void)?

    init(score: Int, highScore: Int, isFirstPlay: Bool, sceneSize: CGSize) {
        super.init()
        buildUI(score: score, highScore: highScore, isFirstPlay: isFirstPlay, sceneSize: sceneSize)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func buildUI(score: Int, highScore: Int, isFirstPlay: Bool, sceneSize: CGSize) {

        let dim = SKShapeNode(rectOf: sceneSize)
        dim.fillColor = UIColor.black.withAlphaComponent(0.55)
        dim.strokeColor = .clear
        dim.zPosition = 0
        addChild(dim)

        let panel = SKSpriteNode(imageNamed: "gameover_panel")

        panel.size = CGSize(
            width: sceneSize.width * 0.68,
            height: sceneSize.height * 0.52
        )

        panel.position = CGPoint(x: 0, y: 0)
        panel.zPosition = 1

        addChild(panel)

        let title = SKSpriteNode(imageNamed: "gameover_text")

        title.size = CGSize(
            width: sceneSize.width * 0.72,
            height: sceneSize.height * 0.26
        )

        title.position = CGPoint(
            x: 0,
            y: panel.size.height * 0.60
        )

        title.zPosition = 2

        panel.addChild(title)

        let scoreLabel = SKLabelNode(fontNamed: "Newyear Coffee")

        scoreLabel.text = String(score)

        scoreLabel.fontSize = 68

        scoreLabel.fontColor = SKColor(
            white: 0.25,
            alpha: 1
        )

        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .center

        scoreLabel.position = CGPoint(x: 0, y: 70)

        scoreLabel.zPosition = 2

        panel.addChild(scoreLabel)

        if !isFirstPlay {

            let hsLabel = SKLabelNode(fontNamed: "Newyear Coffee")

            hsLabel.text = "HIGH SCORE: \(String(highScore))"

            hsLabel.fontSize = 25

            hsLabel.fontColor = SKColor(
                white: 0.25,
                alpha: 1
            )

            hsLabel.verticalAlignmentMode = .center
            hsLabel.horizontalAlignmentMode = .center

            hsLabel.position = CGPoint(x: 0, y: -5)

            hsLabel.zPosition = 2

            panel.addChild(hsLabel)
        }

        panel.addChild(makeButton(
            label: "RETRY",
            width: panel.size.width * 0.72,
            height: 90,
            color: UIColor(white: 0.92, alpha: 1),
            name: "btnRetry",
            y: -140
        ))

        panel.addChild(makeButton(
            label: "BACK TO HOME",
            width: panel.size.width * 0.55,
            height: 64,
            color: UIColor(white: 0.92, alpha: 1),
            name: "btnMainMenu",
            y: -250
        ))

       alpha = 0
        setScale(0.88)

        run(.group([
            .fadeIn(withDuration: 0.25),
            .scale(to: 1.0, duration: 0.25)
        ]))
    }

    func handleTap(at location: CGPoint) {

        guard let parent else { return }

        let localPoint = convert(location, from: parent)

        for node in nodes(at: localPoint) {

            switch node.name {

            case "btnRetry":

                run(.sequence([
                    .scale(to: 0.96, duration: 0.05),
                    .scale(to: 1.0, duration: 0.05)
                ]))

                onRetry?()

            case "btnMainMenu":

                run(.sequence([
                    .scale(to: 0.96, duration: 0.05),
                    .scale(to: 1.0, duration: 0.05)
                ]))

                onMainMenu?()

            default:
                break
            }
        }
    }

    private func makeButton(label: String,
                            width: CGFloat,
                            height: CGFloat,
                            color: UIColor,
                            name: String,
                            y: CGFloat) -> SKNode {

        let container = SKNode()

        container.name = name

        container.position = CGPoint(x: 0, y: y)

        container.zPosition = 2

        let bg = SKShapeNode(
            rectOf: CGSize(width: width, height: height),
            cornerRadius: 22
        )

        bg.fillColor = color

        bg.strokeColor = UIColor(
            white: 0.75,
            alpha: 1
        )

        bg.lineWidth = 5

        bg.name = name

        container.addChild(bg)

        let lbl = SKLabelNode(
            fontNamed: "NewyearCoffee-Regular"
        )

        lbl.text = label

        lbl.fontSize = height > 70 ? 42 : 24

        lbl.fontColor = UIColor(
            white: 0.2,
            alpha: 1
        )

        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center

        lbl.name = name

        container.addChild(lbl)

        return container
    }
}
