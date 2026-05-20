//
//  OptionPopupNode.swift
//  ShamanDefense
//

import UIKit
import SpriteKit

// MARK: - Delegate

protocol OptionPopupDelegate: AnyObject {
    func optionPopupDidRequestClose(_ popup: OptionPopupNode)
}

// MARK: - OptionPopupNode

class OptionPopupNode: SKNode {

    weak var delegate: OptionPopupDelegate?

    // Pakai .shared supaya sinkron dengan PauseOverlayView
    private let optionViewModel = OptionViewModel.shared
    private let sceneSize: CGSize

    private var hapticSwitchNode: SKSpriteNode?
    private var musicKnobNode: SKSpriteNode?
    private var soundKnobNode: SKSpriteNode?
    private var popupBackground: SKSpriteNode?

    private var hapticSwitchImageName: String {
        optionViewModel.hapticEnabled ? "switch_on" : "switch_off"
    }

    // Init tidak lagi terima viewModel dari luar — pakai .shared langsung
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        setupPopup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPopup() {
        setupOverlay()
        setupBackground()
        setupTitle()
        setupMusicSection()
        setupSoundSection()
        setupHapticSection()
    }

    private func setupOverlay() {
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.5), size: sceneSize)
        overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.zPosition = 99
        overlay.name = "overlay"
        addChild(overlay)
    }

    private func setupBackground() {
        let popup = SKSpriteNode(imageNamed: "content_background")
        popup.name = "option_popup"
        popup.position = CGPoint(x: sceneSize.width / 2, y: 430)
        popup.size = CGSize(width: 311, height: 386)
        popup.zPosition = 100
        addChild(popup)
        popupBackground = popup
    }

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
        musicKnob.position = CGPoint(x: CGFloat(optionViewModel.backgroundMusic) * 180 - 90, y: 70)
        musicKnob.zPosition = 1
        popup.addChild(musicKnob)
        musicKnobNode = musicKnob
    }

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
        soundKnob.position = CGPoint(x: CGFloat(optionViewModel.soundEffect) * 180 - 90, y: -30)
        soundKnob.zPosition = 1
        popup.addChild(soundKnob)
        soundKnobNode = soundKnob
    }

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

    func handleTouchBegan(at location: CGPoint, touchedNode: SKNode) {
        switch touchedNode.name {
        case "haptic_switch":
            optionViewModel.hapticEnabled.toggle()
            hapticSwitchNode?.texture = SKTexture(imageNamed: hapticSwitchImageName)
            if optionViewModel.hapticEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        case "music_knob", "sound_knob":
            break
        default:
            if let popup = popupBackground {
                let popupFrame = popup.calculateAccumulatedFrame()
                if !popupFrame.contains(location) {
                    delegate?.optionPopupDidRequestClose(self)
                }
            }
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
}
