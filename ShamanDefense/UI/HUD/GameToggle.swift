//
//  GameToggle.swift
//  ShamanDefense
//

import SwiftUI

struct GameToggle: View {
    @Binding var isOn: Bool
    let label: String

    private let trackWidth: CGFloat = 140
    private let knobWidth: CGFloat = 54
    private let knobHeight: CGFloat = 44

    // inner groove x from clippath-1: x=84.34 to x=445.67 out of 517.32
    private var offX: CGFloat { 84.34 / 517.32 * trackWidth }
    private var onX: CGFloat { 445.67 / 517.32 * trackWidth - knobWidth }
    private var midX: CGFloat { (offX + onX) / 2 }

    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0

    private var knobX: CGFloat {
        if isDragging {
            let base = isOn ? onX : offX
            return min(max(base + dragOffset, offX), onX)
        }
        return isOn ? onX : offX
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom("Newyear Coffee", size: 20))
                .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))

            ZStack(alignment: .leading) {
                Image("toggle_background")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: trackWidth)

                Image("toggle_knob")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: knobWidth, height: knobHeight)
                    .offset(x: knobX)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        isDragging = true
                        dragOffset = drag.translation.width
                    }
                    .onEnded { drag in
                        let base = isOn ? onX : offX
                        let finalX = base + drag.translation.width
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isOn = abs(drag.translation.width) < 5 ? !isOn : finalX > midX
                            isDragging = false
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}

#Preview {
    @Previewable @State var on = true
    GameToggle(isOn: $on, label: "Haptic")
}
