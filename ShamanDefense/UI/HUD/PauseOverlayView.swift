//
//  PauseOverlayView.swift
//  ShamanDefense
//

import SwiftUI

struct PauseOverlayView: View {
    @State private var musicVolume: Float = 0.8
    @State private var sfxVolume: Float = 0.8
    @State private var hapticEnabled: Bool = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

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
                        .frame(maxWidth: 275)

                    VStack(spacing: 24) {
                        GameSlider(value: $musicVolume, label: "Background Music")
                        GameSlider(value: $sfxVolume, label: "Sound Effect")
                        GameToggle(isOn: $hapticEnabled, label: "Haptic")
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    PauseOverlayView()
}
