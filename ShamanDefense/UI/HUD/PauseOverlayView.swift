//
//  PauseOverlayView.swift
//  ShamanDefense
//

import SwiftUI
import SpriteKit

struct PauseOverlayView: View {

    var onContinue: (() -> Void)?
    var onMainMenu: (() -> Void)?

    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: makePauseScene(size: geo.size),
                       options: [.allowsTransparency])
                .ignoresSafeArea()
                .background(Color.clear)
        }
        .ignoresSafeArea()
    }

    private func makePauseScene(size: CGSize) -> SKScene {
        let scene = SKScene(size: size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear

        let popup = PauseSceneNode(
            sceneSize: size,
            onContinue: onContinue,
            onMainMenu: onMainMenu
        )
        scene.addChild(popup)
        return scene
    }
}

#Preview {
    PauseOverlayView()
}
