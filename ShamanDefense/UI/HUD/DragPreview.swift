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

    private static let diameter: CGFloat = GhostMetrics.diameter

    private var validityColor: Color? {
        switch isPlaceable {
        case .some(true):  return .green
        case .some(false): return .red
        case .none:        return nil
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(character.tint)
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                .frame(width: Self.diameter, height: Self.diameter)
            Text(character.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
            if let validityColor {
                Circle()
                    .fill(validityColor.opacity(0.4))
                    .overlay(Circle().stroke(validityColor, lineWidth: 2))
                    .frame(width: Self.diameter, height: Self.diameter)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    DragPreview(character: GameCollection.allCharacters[0])
}
