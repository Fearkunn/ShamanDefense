//
//  MainMenuScene.swift
//  ShamanDefense
//
//  Created by Michael on 15/05/26.
//

import SwiftUI
import SpriteKit

class MainMenuScene: SKScene {
    
    // MARK: - Properties

    /// Di-set oleh ContentView. Dipanggil saat user tap Start.
    var onStartGame: (() -> Void)?
    var onOpenCharacters: (() -> Void)?

    private var optionPopup: OptionScenePopupNode?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupBackground()
        setupLogo()
        setupSettingsButton()
        setupScoreBoard()
        setupStartButton()
        setupCharactersButton()
        setupCharacter()
    }

    // MARK: - Background

    private func setupBackground() {
        childNode(withName: "background")?.removeFromParent()
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "background"
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }

    // MARK: - Logo

    private func setupLogo() {
        childNode(withName: "logo")?.removeFromParent()
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.name = "logo"
        logo.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        logo.size = CGSize(width: 337, height: 132)
        logo.zPosition = 5
        addChild(logo)
    }

    // MARK: - Settings Button

    private func setupSettingsButton() {
        childNode(withName: "settings")?.removeFromParent()
        let settings = SKSpriteNode(imageNamed: "setting")
        settings.name = "settings"
        settings.position = CGPoint(x: size.width - 50, y: size.height - 80)
        settings.size = CGSize(width: 58, height: 59)
        addChild(settings)
    }

    // MARK: - Score Board

    private func setupScoreBoard() {

        // Hapus scoreboard lama jika ada
        childNode(withName: "score_board")?.removeFromParent()

        let board = SKSpriteNode(imageNamed: "score_board")

        board.name = "score_board"

        board.anchorPoint = CGPoint(x: 0.5, y: 0.9)

        board.position = CGPoint(
            x: size.width / 1.7,
            y: size.height * 0.68 + 50
        )

        board.size = CGSize(width: 166, height: 132)

        board.zRotation = -0.15
        board.zPosition = 1

        addChild(board)

        let highScoreLabel = SKLabelNode(fontNamed: "Newyear Coffee")

        highScoreLabel.text = "HIGH SCORE:"
        highScoreLabel.fontSize = 10

        highScoreLabel.fontColor = SKColor(
            red: 75/255,
            green: 75/255,
            blue: 75/255,
            alpha: 1
        )

        highScoreLabel.position = CGPoint(x: 20, y: -77)

        board.addChild(highScoreLabel)

        let scoreLabel = SKLabelNode(fontNamed: "Newyear Coffee")

        scoreLabel.name = "score_label"
        scoreLabel.fontSize = 30

        scoreLabel.fontColor = SKColor(
            red: 75/255,
            green: 75/255,
            blue: 75/255,
            alpha: 1
        )

        scoreLabel.position = CGPoint(x: 20, y: -105)

        board.addChild(scoreLabel)

        updateScoreBoard()
    }
    
    func updateScoreBoard() {

        guard let board = childNode(withName: "score_board") as? SKSpriteNode else { return }

        guard let scoreLabel = board.childNode(withName: "score_label") as? SKLabelNode else { return }

        let hasPlayed = UserDefaults.standard.bool(
            forKey: "ShamanDefense_HasPlayed"
        )

        let score = hasPlayed
            ? UserDefaults.standard.integer(
                forKey: "ShamanDefense_HighScore"
            )
            : 0

        scoreLabel.text = "\(score)"

        startWobbleAnimation(on: board)
    }
    // MARK: - Animation

    private func startWobbleAnimation(on node: SKSpriteNode) {

        if node.action(forKey: "Animation") != nil {
            return
        }

        let swingLeft = SKAction.rotate(
            toAngle: -0.22,
            duration: 1.0
        )

        swingLeft.timingMode = .easeInEaseOut

        let swingRight = SKAction.rotate(
            toAngle: 0.22,
            duration: 1.0
        )

        swingRight.timingMode = .easeInEaseOut

        let sequence = SKAction.sequence([
            swingLeft,
            swingRight
        ])

        node.run(
            SKAction.repeatForever(sequence),
            withKey: "wobble"
        )
    }
    
    private func startBreathingAnimation(on node: SKSpriteNode) {

        // MARK: - Scale Animation

        let breatheIn = SKAction.scale(
            to: 1.01,
            duration: 1.4
        )

        breatheIn.timingMode = .easeInEaseOut

        let breatheOut = SKAction.scale(
            to: 1.0,
            duration: 1.4
        )

        breatheOut.timingMode = .easeInEaseOut

        // MARK: - Floating Animation

        let moveUp = SKAction.moveBy(
            x: 0,
            y: 6,
            duration: 0.5
        )

        moveUp.timingMode = .easeInEaseOut

        let moveDown = SKAction.moveBy(
            x: 0,
            y: -6,
            duration: 0.5
        )

        moveDown.timingMode = .easeInEaseOut

        // MARK: - Combine

        let breatheGroup = SKAction.group([
            breatheIn,
            moveUp
        ])

        let relaxGroup = SKAction.group([
            breatheOut,
            moveDown
        ])

        let sequence = SKAction.sequence([
            breatheGroup,
            relaxGroup
        ])

        node.run(
            SKAction.repeatForever(sequence),
            withKey: "breathing"
        )
    }
    // MARK: - Start Button

    private func setupStartButton() {
        childNode(withName: "start")?.removeFromParent()
        let start = SKSpriteNode(imageNamed: "title_background")
        start.name = "start"
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        start.size = CGSize(width: 254, height: 138)
        addChild(start)

        let label = SKLabelNode(fontNamed: "Newyear Coffee")
        label.text = "Start"
        label.fontSize = 50
        label.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        label.position = CGPoint(x: 0, y: 0)
        start.addChild(label)
    }

    // MARK: - Characters Button

    private func setupCharactersButton() {
        childNode(withName: "characters")?.removeFromParent()
        let characters = SKSpriteNode(imageNamed: "button")
        characters.name = "characters"
        characters.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        characters.size = CGSize(width: 165, height: 52)
        addChild(characters)

        let label = SKLabelNode(fontNamed: "Newyear Coffee")
        label.text = "Characters"
        label.fontSize = 20
        label.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        label.position = CGPoint(x: 0, y: -8)
        characters.addChild(label)
    }

    // MARK: - Main Character

    private func setupCharacter() {
        
        childNode(withName: "main_character")?.removeFromParent()
        let character = SKSpriteNode(imageNamed: "gugun_mainMenu")
        character.name = "main_character"
        
        character.position = CGPoint(
            x: size.width / 2,
            y: size.height * 0.10
        )

        character.size = CGSize(
            width: 280,
            height: 480
        )

        character.zPosition = 0

        addChild(character)

        startBreathingAnimation(on: character)
    }
    
    // MARK: - Navigation

    private func goToGame() {
        guard let startNode = childNode(withName: "start") else { return }

        let scaleDown = SKAction.scale(to: 0.92, duration: 0.08)
        let scaleUp   = SKAction.scale(to: 1.00, duration: 0.08)
        let navigate  = SKAction.run { [weak self] in
            DispatchQueue.main.async {
                self?.onStartGame?()
            }
        }

        startNode.run(.sequence([scaleDown, scaleUp, navigate]))
    }
    
    private func goToCharacters() {
        guard let charactersNode = childNode(withName: "characters") else { return }
        
        let scaleDown = SKAction.scale(to: 0.92, duration: 0.08)
        let scaleUp   = SKAction.scale(to: 1.00, duration: 0.08)
        
        let navigate = SKAction.run { [weak self] in
                DispatchQueue.main.async {
                    self?.onOpenCharacters?()
                }
            }
        
        charactersNode.run(
                .sequence([scaleDown, scaleUp, navigate])
            )

    }
    

    // MARK: - Option Popup

    private func showOptionPopup() {

        let popup = OptionScenePopupNode(
            viewModel: OptionViewModel.shared,
            sceneSize: size
        )

        popup.delegate = self
        popup.zPosition = 99

        addChild(popup)

        optionPopup = popup
    }
    private func closeOptionPopup() {
        optionPopup?.removeFromParent()
        optionPopup = nil
    }

    // MARK: - Touch Began

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location    = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        let nodeName = touchedNode.name ?? touchedNode.parent?.name

        if let popup = optionPopup {
            popup.handleTouchBegan(at: location, touchedNode: touchedNode)
            return
        }

        switch nodeName{
        case "start":
            goToGame()

        case "characters":
            goToCharacters() // TODO: sambungkan ke Characters screen

        case "settings":
            showOptionPopup()

        default:
            break
        }
    }

    // MARK: - Touch Moved

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location    = touch.location(in: self)
        let touchedNode = atPoint(location)
        optionPopup?.handleTouchMoved(at: location, touchedNode: touchedNode)
    }
}

// MARK: - OptionPopupDelegate

extension MainMenuScene: OptionScenePopupDelegate {

    func optionPopupDidRequestClose(
        _ popup: OptionScenePopupNode
    ) {

        closeOptionPopup()
    }
}
// MARK: - Preview

#Preview {
    let scene = MainMenuScene(size: CGSize(width: 390, height: 844))
    scene.scaleMode = .aspectFill
    return SpriteView(scene: scene)
        .ignoresSafeArea()
}
