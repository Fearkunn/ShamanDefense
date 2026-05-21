//
//  HangingScore.swift
//  ShamanDefense
//

import SpriteKit

extension GameScene {
    func buildScoreLabel() {
        let hangingHandle = SKSpriteNode(imageNamed: "hanging_score")
        hangingHandle.zPosition = 100
        hangingHandle.size = CGSize(width: 150, height: 92)
        let handleHalfHeight = hangingHandle.size.height / 2
        hangingHandle.position = CGPoint(
            x: size.width / 2,
            y: size.height - handleHalfHeight
        )
        hudLayer.addChild(hangingHandle)

        let scoreBoard = SKSpriteNode(imageNamed: "board_score")
        scoreBoard.zPosition = 101
        scoreBoard.size = CGSize(width: 150, height: 56)
        scoreBoard.position = CGPoint(x: 0, y: -40)
        hangingHandle.addChild(scoreBoard)

        let titleLabel = GameLabelNode(
            text: "Score:",
            fontSize: 10
        )
        titleLabel.position = CGPoint(
            x: 0,
            y: 15
        )
        titleLabel.zPosition = 102
        scoreBoard.addChild(titleLabel)

        scoreLabel = GameLabelNode(
            text: "0",
            fontSize: 40
        )

        scoreLabel.position = CGPoint(
            x: 0,
            y: -7
        )
        scoreLabel.zPosition = 102
        scoreBoard.addChild(scoreLabel)
    }
}
