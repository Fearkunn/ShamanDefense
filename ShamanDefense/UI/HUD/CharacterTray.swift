//
//  DeploymentTrayHUD.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct CharacterTray: View {
    @Binding var selected: CharacterData?
    var coordSpace: String = "game"
    var onDragChanged: (CharacterData, CGPoint) -> Void = { _, _ in }
    var onDragEnded: (CharacterData, CGPoint) -> Void = { _, _ in }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(GameCollection.allCharacters) { character in
                CharacterCardUI(
                    character: character,
                    onTap: { selected = character }
                )
                .frame(maxWidth: .infinity)
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
}

#Preview {
    StatefulPreviewWrapper()
}

private struct StatefulPreviewWrapper: View {
    @State var selected: CharacterData? = nil
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            VStack { Spacer(); CharacterTray(selected: $selected) }
        }
        .coordinateSpace(name: "game")
    }
}
