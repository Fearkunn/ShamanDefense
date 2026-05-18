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
                .padding(.leading, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 172)
    }

    private func characterTile(for character: CharacterData) -> some View {
        let isSelected = selectedCharacter.id == character.id

        return Image(bottomImageName(for: character.id))
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 220)
    }

    private func bottomImageName(for id: GhostID) -> String {
        switch id {
        case .gugun: return "icon_gugun"
        case .keti: return "icon_keti"
        case .poci: return "icon_poci"
        case .yayang: return "icon_yayang"
        case .yuyul: return "icon_yuyul"
        }
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
