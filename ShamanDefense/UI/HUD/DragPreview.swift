//
//  DragPreview.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct DragPreview: View {
    let character: CharacterData
    let placementRadius: CGFloat
    var isPlaceable: Bool? = nil

    private var validityColor: Color? {
        switch isPlaceable {
        case .some(true):  return .green
        case .some(false): return .red
        case .none:        return nil
        }
    }

    private var spriteH: CGFloat { CharacterSprites.spriteHeight }
    private var isTower: Bool { character.kind == .tower }
    // Image anchors at touch point: tower bottom = touch (sprite stretches up),
    // trap center = touch (sprite centered on hitbox).
    private var imageOffsetY: CGFloat { isTower ? -spriteH / 2 : 0 }
    // Shadow at visual feet: tower feet at touch, trap feet below image center.
    private var shadowOffsetY: CGFloat { isTower ? 0 : spriteH * 0.5 }
    // Validity indicator aligned to placement rule: tower foot above touch, trap centered.
    private var validityOffsetY: CGFloat { isTower ? -placementRadius : 0 }

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
                .offset(y: shadowOffsetY)
                .blur(radius: 0.5)
                .allowsHitTesting(false)
            Image("\(character.id.rawValue)_bottom")
                .resizable()
                .scaledToFit()
                .frame(height: spriteH)
                .offset(y: imageOffsetY)
            if let validityColor {
                let d = placementRadius * 2
                Circle()
                    .fill(validityColor.opacity(0.35))
                    .overlay(Circle().stroke(validityColor, lineWidth: 2))
                    .frame(width: d, height: d)
                    .offset(y: validityOffsetY)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    DragPreview(character: GameCollection.allCharacters[0], placementRadius: 20)
}
