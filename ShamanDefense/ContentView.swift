//
//  ContentView.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SwiftUI
import SpriteKit

// MARK: - App Navigation State

enum AppScreen {
    case mainMenu
    case story
    case game
    case characters
}

// MARK: - ContentView

struct ContentView: View {

    @State private var screen: AppScreen = .mainMenu

    // Buat scene sekali, simpan di State supaya tidak re-create saat view rebuild
    @State private var menuScene: MainMenuScene = {
        let scene = MainMenuScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }()

    var body: some View {
        Group {
            switch screen {
                
            case .mainMenu:
                GeometryReader { geo in
                    SpriteView(scene: menuScene)
                        .ignoresSafeArea()
                        .onAppear {
                            // Update ukuran scene sesuai layar aktual
                            menuScene.size = geo.size
                            // Sambungkan callback Start ke sini
                            menuScene.onStartGame = {
                                screen = .story
                            }
                            menuScene.onOpenCharacters = {
                                screen = .characters
                            }

                        }
                }
                .ignoresSafeArea()
                
            case .story:
                StartStoryScreen {
                    screen = .game
                }
                
            case .game:
                GameScreen(onMainMenu: {
                    menuScene.updateScoreBoard()
                    screen = .mainMenu
                })
                
            case .characters:
                CharactersScreen(
                    onBack: {
                                screen = .mainMenu
                            }
                )
                
            }
        }
        .animation(.easeInOut(duration: 0.4), value: screen)
    }
}
