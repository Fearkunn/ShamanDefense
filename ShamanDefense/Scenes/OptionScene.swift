//
//  OptionScene.swift
//  ShamanDefense
//
//  Created by Michael on 15/05/26.
//

import UIKit
import SwiftUI
import SpriteKit

// MARK: - Delegate

protocol OptionScenePopupDelegate: AnyObject {
    func optionPopupDidRequestClose(_ popup: OptionScenePopupNode)
}

// MARK: - OptionScenePopupNode

class OptionScenePopupNode: SKNode {

    // MARK: - Properties

    weak var delegate: OptionScenePopupDelegate?

    private let optionViewModel: OptionViewModel
    private let sceneSize: CGSize

    private var hapticSwitchNode: SKSpriteNode?
    private var musicKnobNode: SKSpriteNode?
    private var soundKnobNode: SKSpriteNode?
    private var popupBackground: SKSpriteNode?

    private var hapticSwitchImageName: String {
        optionViewModel.hapticEnabled ? "switch_on" : "switch_off"
    }

    // MARK: - Init

    init(viewModel: OptionViewModel, sceneSize: CGSize) {
        self.optionViewModel = viewModel
        self.sceneSize = sceneSize
        super.init()
        setupPopup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPopup() {
        setupOverlay()
        setupBackground()
        setupTitle()
        setupBackButton()
        setupMusicSection()
        setupSoundSection()
        setupHapticSection()
    }

    // MARK: - Overlay

    private func setupOverlay() {
        let overlay = SKSpriteNode(
            color: .black.withAlphaComponent(0.5),
            size: sceneSize
        )
        overlay.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height / 2
        )
        overlay.zPosition = 99
        overlay.name = "overlay"
        addChild(overlay)
    }

    // MARK: - Popup Background

    private func setupBackground() {
        let popup = SKSpriteNode(imageNamed: "content_background")
        popup.name = "option_popup"
        popup.position = CGPoint(x: sceneSize.width / 2, y: 430)
        popup.size = CGSize(width: 311, height: 386)
        popup.zPosition = 100
        addChild(popup)
        popupBackground = popup
    }

    // MARK: - Title

    private func setupTitle() {
        guard let popup = popupBackground else { return }

        let titleBackground = SKSpriteNode(imageNamed: "title_background")
        titleBackground.size = CGSize(width: 244, height: 119)
        titleBackground.position = CGPoint(x: 0, y: 170)
        popup.addChild(titleBackground)

        let titleLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        titleLabel.text = "OPTION"
        titleLabel.fontSize = 45
        titleLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 190)
        popup.addChild(titleLabel)
    }

    // MARK: - Music Section

    private func setupMusicSection() {
        guard let popup = popupBackground else { return }

        let musicLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        musicLabel.text = "BACKGROUND MUSIC"
        musicLabel.fontSize = 19
        musicLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        musicLabel.position = CGPoint(x: 0, y: 110)
        popup.addChild(musicLabel)

        let musicBar = SKSpriteNode(imageNamed: "slider_background")
        musicBar.size = CGSize(width: 242, height: 55)
        musicBar.position = CGPoint(x: 0, y: 70)
        popup.addChild(musicBar)

        let musicKnob = SKSpriteNode(imageNamed: "slider_knob")
        musicKnob.size = CGSize(width: 40, height: 40)
        musicKnob.name = "music_knob"
        musicKnob.position = CGPoint(
            x: CGFloat(optionViewModel.backgroundMusic) * 180 - 90,
            y: 70
        )
        musicKnob.zPosition = 1
        popup.addChild(musicKnob)
        musicKnobNode = musicKnob
    }

    // MARK: - Sound Section

    private func setupSoundSection() {
        guard let popup = popupBackground else { return }

        let soundLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        soundLabel.text = "SOUND EFFECT"
        soundLabel.fontSize = 19
        soundLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        soundLabel.position = CGPoint(x: 0, y: 10)
        popup.addChild(soundLabel)

        let soundBar = SKSpriteNode(imageNamed: "slider_background")
        soundBar.size = CGSize(width: 242, height: 55)
        soundBar.position = CGPoint(x: 0, y: -30)
        popup.addChild(soundBar)

        let soundKnob = SKSpriteNode(imageNamed: "slider_knob")
        soundKnob.size = CGSize(width: 40, height: 40)
        soundKnob.name = "sound_knob"
        soundKnob.position = CGPoint(
            x: CGFloat(optionViewModel.soundEffect) * 180 - 90,
            y: -30
        )
        soundKnob.zPosition = 1
        popup.addChild(soundKnob)
        soundKnobNode = soundKnob
    }

    // MARK: - Haptic Section

    private func setupHapticSection() {
        guard let popup = popupBackground else { return }

        let hapticLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        hapticLabel.text = "HAPTIC"
        hapticLabel.fontSize = 19
        hapticLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        hapticLabel.position = CGPoint(x: -50, y: -130)
        popup.addChild(hapticLabel)

        let haptic = SKSpriteNode(imageNamed: hapticSwitchImageName)
        haptic.size = CGSize(width: 120, height: 60)
        haptic.name = "haptic_switch"
        haptic.position = CGPoint(x: 60, y: -120)
        popup.addChild(haptic)
        hapticSwitchNode = haptic
    }

    // MARK: - Public Touch Handlers
    // Dipanggil langsung dari MainMenuScene

    func handleTouchBegan(at location: CGPoint, touchedNode: SKNode) {
        switch touchedNode.name {
            
        case "close_popup":
            delegate?.optionPopupDidRequestClose(self)
            
        case "haptic_switch":
            optionViewModel.hapticEnabled.toggle()
            hapticSwitchNode?.texture = SKTexture(imageNamed: hapticSwitchImageName)
            HapticManager.shared.impact(.medium)

        case "music_knob", "sound_knob":
            break // Ditangani di handleTouchMoved

        default:
            break
        }
    }

    func handleTouchMoved(at location: CGPoint, touchedNode: SKNode) {
        guard let popup = popupBackground else { return }

        let minX = popup.position.x - 90
        let maxX = popup.position.x + 90

        switch touchedNode.name {

        case "music_knob":
            let clampedX = max(min(location.x, maxX), minX)
            musicKnobNode?.position.x = clampedX - popup.position.x
            optionViewModel.backgroundMusic = Float((clampedX - minX) / 180)

        case "sound_knob":
            let clampedX = max(min(location.x, maxX), minX)
            soundKnobNode?.position.x = clampedX - popup.position.x
            optionViewModel.soundEffect = Float((clampedX - minX) / 180)

        default:
            break
        }
    }
    
    // MARK: - Back Button

    private func setupBackButton() {

        guard let popup = popupBackground else { return }

        let backButton = SKSpriteNode(imageNamed: "continue")

        backButton.name = "close_popup"

        backButton.size = CGSize(
            width: 60,
            height: 60
        )

        // Mirror horizontal
        backButton.xScale = -1

        backButton.position = CGPoint(
            x: -140,
            y: 365
        )

        backButton.zPosition = 5

        popup.addChild(backButton)
    }
}

#Preview {
    let scene: SKScene = {
        let scene = SKScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear

        let popup = OptionScenePopupNode(
            viewModel: OptionViewModel.shared,
            sceneSize: scene.size
        )
        scene.addChild(popup)
        return scene
    }()

    SpriteView(scene: scene)
        .ignoresSafeArea()
}
