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
    @State private var currentWave: Int = 0
    @State private var selected: CharacterData? = nil
    @State private var dragging: (character: CharacterData, location: CGPoint)? = nil
    @State private var waveWarning: WaveWarningBannerData? = nil
    @State private var isPaused = false
    @State private var gameOver: GameOverOverlayData? = nil
    @State private var currentSpirit: Int = 10
    var onMainMenu: (() -> Void)? = nil


    var body: some View {
        GeometryReader { geo in
            let dropZoneHeight = geo.size.height - trayHeight

            ZStack(alignment: .top) {
                SpriteView(scene: scene, debugOptions: [.showsFPS, .showsPhysics, .showsNodeCount])
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                    .onAppear {
                                scene.onMainMenu = onMainMenu
                            }
                VStack {
                    Spacer()
                    CharacterTray(
                        selected: $selected,
                        currentSpirit: currentSpirit,
                        coordSpace: gameCoordSpace,
                        onDragChanged: { character, location in
                            dragging = (character, location)
                        },
                        onDragEnded: { character, location in
                            dragging = nil
                            guard location.y < dropZoneHeight else { return false }
                            let liftedY = location.y - dragLift
                            let scenePoint = CGPoint(
                                x: location.x,
                                y: geo.size.height - liftedY
                            )
                            return scene.place(character, at: scenePoint)
                        }
                    ).padding(.bottom, 30).padding(.horizontal, 10)
                }

                if isPaused || gameOver != nil || waveWarning != nil {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(8)
                        .allowsHitTesting(isPaused || gameOver != nil)
                }

                if isPaused {
                    PauseOverlayView(
                        onContinue: {
                            isPaused = false
                            scene.pauseComponent?.isPaused = false
                        },
                        onMainMenu: {
                            onMainMenu?()// TODO: navigate to main menu
                        }
                    )
                    .zIndex(11)
                }

                if let data = gameOver {
                    GameOverOverlayView(
                        data: data,
                        onRetry: {
                            gameOver = nil
                            scene.restartGame()
                        },
                        onMainMenu: {
                            gameOver = nil
                            scene.goToMainMenu()
                        }
                    )
                    .zIndex(12)
                }

                HStack {
                    Spacer()
                    PauseButton(isPaused: isPaused) {
                        isPaused.toggle()
                        scene.pauseComponent?.isPaused = isPaused
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 32)
                }

                if let drag = dragging, drag.location.y < dropZoneHeight {
                    let liftedY = drag.location.y - dragLift
                    let scenePoint = CGPoint(x: drag.location.x, y: geo.size.height - liftedY)
                    let placeable = scene.canPlace(drag.character, at: scenePoint)
                    DragPreview(character: drag.character,
                                placementRadius: scene.dragIndicatorRadius(for: drag.character.kind),
                                isPlaceable: placeable)
                        .position(x: drag.location.x, y: liftedY)
                        .opacity(0.85)
                        .allowsHitTesting(false)
                }

                if let waveWarning {
                    WaveWarningBanner(data: waveWarning)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: waveWarning)
            .animation(.easeInOut(duration: 0.22), value: isPaused)
            .coordinateSpace(name: gameCoordSpace)
            .onAppear {
                wireSceneCallbacks()
            }
        }
        .ignoresSafeArea()
    }

    private func wireSceneCallbacks() {
        scene.onIntermission = { nextWave in
            showIncomingWaveWarning(waveNumber: nextWave)
        }
        scene.onWaveStart = { wave in
            currentWave = wave
        }
        scene.onRetry = {
            currentWave = 0
            selected = nil
            dragging = nil
            waveWarning = nil
            isPaused = false
            gameOver = nil
        }
        scene.onSpiritChanged = { value in
            currentSpirit = value
        }
        scene.onGameOver = { score, high, isFirst in
            withAnimation(.easeInOut(duration: 0.22)) {
                gameOver = GameOverOverlayData(score: score, highScore: high, isFirstPlay: isFirst)
            }
        }
    }

    private func showIncomingWaveWarning(waveNumber: Int) {
        waveWarning = WaveWarningBannerData(
            title: "A wave of human is approaching"
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
