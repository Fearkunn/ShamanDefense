//
//  DragPreview.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct DragPreview: View {
    let character: CharacterData
    var isPlaceable: Bool? = nil

    private var validityColor: Color? {
        switch isPlaceable {
        case .some(true):  return .green
        case .some(false): return .red
        case .none:        return nil
        }
    }

    var body: some View {
        ZStack {
            if let range = character.range {
                Circle()
                    .fill(character.tint.opacity(0.12))
                    .overlay(
                        Circle().strokeBorder(
                            character.tint.opacity(0.7),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                    )
                    .frame(width: range * 2, height: range * 2)
                    .allowsHitTesting(false)
            }
            Ellipse()
                .fill(Color.black.opacity(0.20))
                .frame(width: GhostMetrics.diameter + 6, height: (GhostMetrics.diameter + 6) * 0.38)
                .offset(y: CharacterSprites.spriteHeight * 0.50)
                .blur(radius: 0.5)
                .allowsHitTesting(false)
            Image("\(character.id.rawValue)_bottom")
                .resizable()
                .scaledToFit()
                .frame(height: CharacterSprites.spriteHeight)
            if let validityColor {
                Circle()
                    .fill(validityColor.opacity(0.4))
                    .overlay(Circle().stroke(validityColor, lineWidth: 2))
                    .frame(width: GhostMetrics.diameter, height: GhostMetrics.diameter)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    DragPreview(character: GameCollection.allCharacters[0])
}
