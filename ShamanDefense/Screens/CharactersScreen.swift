//
//  CharactersScreen.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 11/05/26.
//

import SwiftUI

struct CharactersScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCharacter: CharacterData = GameCollection.allCharacters.first ?? CharacterData(
        id: .keti,
        name: "Keti",
        cost: 3,
        description: "Keti attacks with piercing sound waves that disable humans.",
        symbol: "flame.fill",
        tint: .orange,
        kind: .tower
    )

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 10)
                    .padding(.horizontal, 18)

                CharacterDetailCardView(
                    selectedCharacter: selectedCharacter
                )
                .padding(.horizontal, 18)
                .padding(.top, 12)

                CharacterSelectionStripView(
                    selectedCharacter: selectedCharacter,
                    onSelectCharacter: { character in
                        selectedCharacter = character
                    }
                )
                .padding(.horizontal, 34)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.18)))
            }

            Spacer()
        }
    }
}

#Preview {
    CharactersScreen()
}
