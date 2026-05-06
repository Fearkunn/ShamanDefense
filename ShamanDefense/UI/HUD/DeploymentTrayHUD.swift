//
//  DeploymentTrayHUD.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct DeploymentTrayHUD: View {
    @Binding var selected: CharacterData?
    var coordSpace: String = "game"
    var onDragChanged: (CharacterData, CGPoint) -> Void = { _, _ in }
    var onDragEnded: (CharacterData, CGPoint) -> Void = { _, _ in }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.4))

            HStack(spacing: 10) {
                ForEach(GameCollection.allCharacters) { character in
                    CharacterCardUI(
                        character: character,
                        isSelected: selected == character,
                        onTap: { selected = character }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .named(coordSpace))
                            .onChanged { value in
                                selected = character
                                onDragChanged(character, value.location)
                            }
                            .onEnded { value in
                                onDragEnded(character, value.location)
                            }
                    )
                }
            }
        }
        .frame(height: 120)
    }
}

#Preview {
    StatefulPreviewWrapper()
}

private struct StatefulPreviewWrapper: View {
    @State var selected: CharacterData? = nil
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            VStack { Spacer(); DeploymentTrayHUD(selected: $selected) }
        }
        .coordinateSpace(name: "game")
    }
}
