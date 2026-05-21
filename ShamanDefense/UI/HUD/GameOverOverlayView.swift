//
//  GameOverOverlayView.swift
//  ShamanDefense
//

import SwiftUI

struct GameOverOverlayData: Equatable {
    let score: Int
    let highScore: Int
    let isFirstPlay: Bool
}

struct GameOverOverlayView: View {
    let data: GameOverOverlayData
    var onRetry: (() -> Void)?
    var onMainMenu: (() -> Void)?

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let panelW = geo.size.width * 0.75
            let panelH = panelW * 1.25
            let titleW = geo.size.width * 0.72
            let titleH = titleW * 0.67
            let labelColor = Color(white: 0.25)
            let displayedHighScore = data.isFirstPlay ? data.score : data.highScore

            ZStack {
                // Panel
                Image("content_background")
                    .resizable()
                    .frame(width: panelW, height: panelH)
                    .overlay(
                        ZStack {
                            // Title (SK y = +panelH*0.60 above panel center)
                            Image("gameover_text")
                                .resizable()
                                .scaledToFit()
                                .frame(width: titleW, height: titleH)
                                .position(x: panelW / 2, y: panelH / 2 - panelH * 0.60)

                            // Score
                            Text("\(data.score)")
                                .font(.custom("Newyear Coffee", size: 68))
                                .foregroundStyle(labelColor)
                                .position(x: panelW / 2, y: panelH / 2 - 105)

                            // High score
                            Text("HIGH SCORE: \(displayedHighScore)")
                                .font(.custom("Newyear Coffee", size: 25))
                                .foregroundStyle(labelColor)
                                .position(x: panelW / 2, y: panelH / 2 - 45)

                            // Retry button (y = -55 from panel center → panelH/2 + 55 from top)
                            overlayButton(text: "retry",
                                          width: panelW * 0.85,
                                          height: 70,
                                          fontSize: 38,
                                          action: { onRetry?() })
                                .position(x: panelW / 2, y: panelH / 2 + 45)

                            // Home button (y = -130 from panel center)
                            overlayButton(text: "BACK TO HOME",
                                          width: panelW * 0.65,
                                          height: 55,
                                          fontSize: 20,
                                          action: { onMainMenu?() })
                                .position(x: panelW / 2, y: panelH / 2 + 120)
                        }
                    )
                    .position(x: geo.size.width / 2, y: geo.size.height / 2 + 50)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1.0 : 0.88)
            .onAppear {
                withAnimation(.easeOut(duration: 0.25)) {
                    appeared = true
                }
            }
        }
    }

    @ViewBuilder
    private func overlayButton(text: String, width: CGFloat, height: CGFloat, fontSize: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image("button")
                    .resizable()
                    .frame(width: width, height: height)
                Text(text)
                    .font(.custom("Newyear Coffee", size: fontSize))
                    .foregroundStyle(Color(white: 0.2))
            }
        }
        .buttonStyle(GameOverButtonStyle())
    }
}

private struct GameOverButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.05), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.55).ignoresSafeArea()
        GameOverOverlayView(data: GameOverOverlayData(score: 42, highScore: 88, isFirstPlay: false))
    }
}
