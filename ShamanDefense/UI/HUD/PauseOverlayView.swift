//
//  PauseOverlayView.swift
//  ShamanDefense
//

import SwiftUI

struct PauseOverlayView: View {
    @State private var musicVolume: Float = 0.8
    @State private var sfxVolume: Float = 0.8
    @State private var hapticEnabled: Bool = true

    var onContinue: (() -> Void)?
    var onMainMenu: (() -> Void)?

    var body: some View {
        VStack(spacing: -80) {
            ZStack {
                Image("title_background")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 220)

                Text("PAUSED")
                    .font(.custom("Newyear Coffee", size: 38))
                    .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
                    .offset(y: -18)
            }.zIndex(1)

            ZStack {
                Image("content_background")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)

                VStack(spacing: 24) {
                    GameSlider(value: $musicVolume, label: "Background Music")
                    GameSlider(value: $sfxVolume, label: "Sound Effect")
                    GameToggle(isOn: $hapticEnabled, label: "Haptic")
                }
                .padding(.top, 20)
            }

            VStack(spacing: 16) {
                Button(action: { onContinue?() }) {
                    ZStack {
                        Image("button")
                            .resizable()
                            .frame(width: 250, height: 70)
                        Text("continue")
                            .font(.custom("Newyear Coffee", size: 38))
                            .foregroundStyle(Color(white: 0.2))
                    }
                }
                .buttonStyle(GameButtonStyle())

                Button(action: { onMainMenu?() }) {
                    ZStack {
                        Image("button")
                            .resizable()
                            .frame(width: 180, height: 55)
                        Text("BACK TO HOME")
                            .font(.custom("Newyear Coffee", size: 20))
                            .foregroundStyle(Color(white: 0.2))
                    }
                }
                .buttonStyle(GameButtonStyle())
            }
            .padding(.top, 96)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.05), value: configuration.isPressed)
    }
}

#Preview {
    PauseOverlayView()
}
