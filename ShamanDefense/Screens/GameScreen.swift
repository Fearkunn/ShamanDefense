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
private let dragLift: CGFloat = 40

struct GameScreen: View {
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()
    @State private var selected: CharacterData? = nil
    @State private var dragging: (character: CharacterData, location: CGPoint)? = nil
    @State private var waveWarning: WaveWarningBannerData? = nil
    @State private var isPaused = false

    var body: some View {
        GeometryReader { geo in
            let sceneHeight = geo.size.height - trayHeight

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    SpriteView(scene: scene, debugOptions: [.showsFPS, .showsPhysics, .showsNodeCount])
                        .frame(height: sceneHeight)

                    DeploymentTrayHUD(
                        selected: $selected,
                        coordSpace: gameCoordSpace,
                        onDragChanged: { character, location in
                            dragging = (character, location)
                        },
                        onDragEnded: { character, location in
                            dragging = nil
                            guard location.y < sceneHeight else { return }
                            let liftedY = location.y - dragLift
                            let scenePoint = CGPoint(
                                x: location.x,
                                y: sceneHeight - liftedY
                            )
                            scene.place(character, at: scenePoint)
                        }
                    )
                    .frame(height: trayHeight)
                }
                
                if isPaused {
                    PauseOverlayView()
                }

                HStack {
                    Spacer()
                    PauseButton(isPaused: isPaused) {
                        isPaused.toggle()
                        scene.pauseComponent?.isPaused = isPaused
                    }
                    .padding()
                }

                if let drag = dragging, drag.location.y < sceneHeight {
                    let liftedY = drag.location.y - dragLift
                    let scenePoint = CGPoint(x: drag.location.x, y: sceneHeight - liftedY)
                    let placeable = scene.canPlace(drag.character, at: scenePoint)
                    DragPreview(character: drag.character, isPlaceable: placeable)
                        .position(x: drag.location.x, y: liftedY)
                        .opacity(0.85)
                        .allowsHitTesting(false)
                }

                if let waveWarning {
                    WaveWarningBanner(data: waveWarning)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: waveWarning)
            .coordinateSpace(name: gameCoordSpace)
        }
    }

    // Hook this to WaveManager / system callback later.
    private func showIncomingWaveWarning(waveNumber: Int) {
        waveWarning = WaveWarningBannerData(
            title: "WAVE \(waveNumber) INCOMING",
            subtitle: "Prepare your defenses"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation {
                waveWarning = nil
            }
        }
    }
}

#Preview {
    GameScreen()
}
