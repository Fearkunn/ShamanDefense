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

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(GameCollection.allCharacters) { character in
                            Button {
                                onSelectCharacter(character)
                            } label: {
                                characterTile(for: character)
                            }
                            .buttonStyle(.plain)
                            .id(character.id)
                        }
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .padding(.bottom, 20)
                }
                .onAppear {
                    proxy.scrollTo(selectedCharacter.id, anchor: .center)
                }
                .onChange(of: selectedCharacter.id) { selectedID in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(selectedID, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 172)
    }

    private func characterTile(for character: CharacterData) -> some View {
        let isSelected = selectedCharacter.id == character.id

        return Image(bottomImageName(for: character.id))
            .resizable()
            .scaledToFit()
            .frame(width: 110, height: 200)
            .scaleEffect(isSelected ? 1.08 : 0.92)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
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
