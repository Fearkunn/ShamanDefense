//
//  GameScreen.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SpriteKit
import SwiftUI

private let gameCoordSpace = "game"
private let trayHeight: CGFloat = 120

struct GameScreen: View {
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()
    @State private var selected: CharacterData? = nil
    @State private var dragging: (character: CharacterData, location: CGPoint)? = nil

    var body: some View {
        GeometryReader { geo in
            let fieldMaxY = geo.size.height - trayHeight

            ZStack {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .onAppear { scene.size = geo.size }
                    .onChange(of: geo.size) { _, newSize in scene.size = newSize }

                if let drag = dragging, drag.location.y < fieldMaxY {
                    PlaceholderPreview(character: drag.character)
                        .position(drag.location)
                        .opacity(0.7)
                        .allowsHitTesting(false)
                }

                VStack(spacing: 0) {
                    Spacer()
                    DeploymentTrayHUD(
                        selected: $selected,
                        coordSpace: gameCoordSpace,
                        onDragChanged: { character, location in
                            dragging = (character, location)
                        },
                        onDragEnded: { character, location in
                            dragging = nil
                            guard location.y < fieldMaxY else { return }
                            let scenePoint = CGPoint(
                                x: location.x,
                                y: geo.size.height - location.y
                            )
                            scene.place(character, at: scenePoint)
                        }
                    )
                }
            }
            .coordinateSpace(name: gameCoordSpace)
        }
    }
}

private struct PlaceholderPreview: View {
    let character: CharacterData
    var body: some View {
        ZStack {
            Circle()
                .fill(character.tint)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .frame(width: 56, height: 56)
            Text(character.name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    GameScreen()
}
