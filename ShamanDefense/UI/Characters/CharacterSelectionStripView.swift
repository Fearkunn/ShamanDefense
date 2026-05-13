//
//  CharacterSelectionStripView.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 11/05/26.
//

import SwiftUI

struct CharacterSelectionStripView: View {
    let selectedCharacter: CharacterData
    let onSelectCharacter: (CharacterData) -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.18))
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(GameCollection.allCharacters) { character in
                        Button {
                            onSelectCharacter(character)
                        } label: {
                            characterTile(for: character)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
        }
        .frame(height: 172)
    }

    private func characterTile(for character: CharacterData) -> some View {
        let isSelected = selectedCharacter.id == character.id

        return RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.3))
            .frame(width: 96, height: 146)
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(character.tint.opacity(0.97))
                    .padding(4)
                    .overlay(
                        Image(systemName: character.symbol)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(Color.black.opacity(0.22), lineWidth: 1.2)
                            .padding(4)
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.white : Color.black.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

#Preview {
    CharacterSelectionStripView(
        selectedCharacter: GameCollection.allCharacters[0],
        onSelectCharacter: { _ in }
    )
    .padding()
    .background(Color.black)
}
