//
//  PauseScene.swift
//  ShamanDefense
//
//  Created by Michael on 20/05/26.
//

import UIKit
import SpriteKit
import SwiftUI

class PauseSceneNode: SKNode {

    // MARK: - Properties

    private let optionViewModel = OptionViewModel.shared
    private let sceneSize: CGSize

    private var onContinue: (() -> Void)?
    private var onMainMenu: (() -> Void)?

    private var hapticSwitchNode: SKSpriteNode?
    private var musicKnobNode: SKSpriteNode?
    private var soundKnobNode: SKSpriteNode?
    private var popupBackground: SKSpriteNode?

    private var hapticSwitchImageName: String {
        optionViewModel.hapticEnabled ? "switch_on" : "switch_off"
    }

    // MARK: - Init

    init(sceneSize: CGSize, onContinue: (() -> Void)?, onMainMenu: (() -> Void)?) {
        self.sceneSize = sceneSize
        self.onContinue = onContinue
        self.onMainMenu = onMainMenu
        super.init()
        isUserInteractionEnabled = true
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
        setupMusicSection()
        setupSoundSection()
        setupHapticSection()
        setupButtons()
    }

    // MARK: - Overlay

    private func setupOverlay() {
        let overlay = SKSpriteNode(
            color: .black.withAlphaComponent(0.5),
            size: sceneSize
        )
        overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.zPosition = 99
        overlay.name = "overlay"
        addChild(overlay)
    }

    // MARK: - Popup Background (ukuran identik dengan Option)

    private func setupBackground() {
        let popup = SKSpriteNode(imageNamed: "content_background")
        popup.name = "pause_popup"
        popup.position = CGPoint(x: sceneSize.width / 2, y: 500)
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
        titleLabel.text = "PAUSED"
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

    // MARK: - Buttons (di luar popup background agar bg tidak memanjang)

    private func setupButtons() {
        guard let popup = popupBackground else { return }

        let popupBottomY = popup.position.y - popup.size.height / 2

        // Continue
        let continueBtn = SKSpriteNode(imageNamed: "button")
        continueBtn.name = "btn_continue"
        continueBtn.size = CGSize(width: 250, height: 70)
        continueBtn.position = CGPoint(x: sceneSize.width / 2, y: popupBottomY - 55)
        continueBtn.zPosition = 100
        addChild(continueBtn)

        let continueLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        continueLabel.name = "btn_continue_label"
        continueLabel.text = "continue"
        continueLabel.fontSize = 38
        continueLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        continueLabel.verticalAlignmentMode = .center
        continueLabel.position = CGPoint(x: 0, y: 0)
        continueBtn.addChild(continueLabel)

        // Back to Home
        let homeBtn = SKSpriteNode(imageNamed: "button")
        homeBtn.name = "btn_home"
        homeBtn.size = CGSize(width: 190, height: 52)
        homeBtn.position = CGPoint(x: sceneSize.width / 2, y: popupBottomY - 130)
        homeBtn.zPosition = 100
        addChild(homeBtn)

        let homeLabel = SKLabelNode(fontNamed: "Newyear Coffee")
        homeLabel.name = "btn_home_label"
        homeLabel.text = "BACK TO HOME"
        homeLabel.fontSize = 20
        homeLabel.fontColor = SKColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        homeLabel.verticalAlignmentMode = .center
        homeLabel.position = CGPoint(x: 0, y: -0)
        homeBtn.addChild(homeLabel)
    }

    // MARK: - Resolve Button
    // atPoint() bisa return SKLabelNode (child) saat tap di tengah tombol.
    // Fungsi ini naik ke parent sampai ketemu node btn_* yang benar.

    private func resolveButton(from node: SKNode) -> SKNode {
        var current: SKNode? = node
        while let n = current {
            if let name = n.name, name.hasPrefix("btn_") && !name.hasSuffix("_label") {
                return n
            }
            current = n.parent
        }
        return node
    }

    // MARK: - Touch Began

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let scene else { return }
        let location    = touch.location(in: scene)
        let rawNode     = scene.atPoint(location)

        // Naik ke parent jika yang disentuh label di dalam tombol
        let buttonNode  = resolveButton(from: rawNode)

        switch buttonNode.name {

        case "btn_continue":
            animateTap(buttonNode) { [weak self] in
                self?.onContinue?()
            }

        case "btn_home":
            animateTap(buttonNode) { [weak self] in
                self?.onMainMenu?()
            }

        case "haptic_switch":
            optionViewModel.hapticEnabled.toggle()
            hapticSwitchNode?.texture = SKTexture(imageNamed: hapticSwitchImageName)
            if optionViewModel.hapticEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }

        case "music_knob", "sound_knob":
            break

        default:
            break
        }
    }

    // MARK: - Touch Moved

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let scene else { return }
        guard let popup = popupBackground else { return }

        let location    = touch.location(in: scene)
        let touchedNode = scene.atPoint(location)

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

    // MARK: - Tap Animation

    private func animateTap(_ node: SKNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.92, duration: 0.07)
        let scaleUp   = SKAction.scale(to: 1.00, duration: 0.07)
        let done      = SKAction.run(completion)
        node.run(.sequence([scaleDown, scaleUp, done]))
    }
}

#Preview {
    let scene: SKScene = {
        let scene = SKScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear

        let popup = PauseSceneNode(
            sceneSize: scene.size,
            onContinue: nil,
            onMainMenu: nil
        )
        scene.addChild(popup)
        return scene
    }()

    SpriteView(scene: scene)
        .ignoresSafeArea()
}
