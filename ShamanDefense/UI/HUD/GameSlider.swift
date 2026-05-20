//
//  GameSlider.swift
//  ShamanDefense
//

import SwiftUI

struct GameSlider: View {

    @Binding var value: Float

    let label: String

    private let trackWidth: CGFloat = 220
    private let knobSize: CGFloat = 30
    private let fillHeight: CGFloat = 10

    // SVG positioning
    private var trackStart: CGFloat {
        58.0 / 544.95 * trackWidth
    }

    private var trackEnd: CGFloat {
        490.0 / 544.95 * trackWidth
    }

    private var usableWidth: CGFloat {
        trackEnd - trackStart
    }

    private var knobX: CGFloat {
        trackStart + CGFloat(value) * usableWidth - knobSize / 2
    }

    // Width progress hijau
    private var fillWidth: CGFloat {
        CGFloat(value) * usableWidth
    }

    var body: some View {

        VStack(spacing: 4) {

            // MARK: - Label

            Text(label)
                .font(.custom("Newyear Coffee", size: 20))
                .foregroundStyle(
                    Color(
                        red: 75/255,
                        green: 75/255,
                        blue: 75/255
                    )
                )

            // MARK: - Slider

            ZStack(alignment: .leading) {

                // Background Slider

                Image("slider_background")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: trackWidth)

                // Green Progress Fill

                Capsule()
                    .fill(
                        Color(
                            red: 120/255,
                            green: 220/255,
                            blue: 90/255
                        )
                    )
                    .frame(
                        width: fillWidth,
                        height: fillHeight
                    )
                    .offset(
                        x: trackStart,
                        y: 0
                    )

                // Knob

                Image("slider_knob")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: knobSize,
                        height: knobSize
                    )
                    .offset(x: knobX)
            }
            .frame(height: knobSize)

            // MARK: - Drag Gesture

            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in

                        let x = drag.location.x

                        let clamped = min(
                            max(x, trackStart),
                            trackEnd
                        )

                        value = Float(
                            (clamped - trackStart)
                            / usableWidth
                        )
                    }
            )
        }
    }
}

#Preview {

    @Previewable @State var vol: Float = 0.8

    GameSlider(
        value: $vol,
        label: "Background Music"
    )
}
