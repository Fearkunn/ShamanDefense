//
//  DeploymentTrayHUD.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct CharacterTray: View {
    @Binding var selected: CharacterData?
    var currentSpirit: Int = .max
    var coordSpace: String = "game"
    var onDragChanged: (CharacterData, CGPoint) -> Void = { _, _ in }
    var onDragEnded: (CharacterData, CGPoint) -> Bool = { _, _ in false }

    @State private var cooldownEndDates: [GhostID: Date] = [:]

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(GameCollection.allCharacters) { character in
                let cooldownEndDate = cooldownEndDates[character.id]
                let isSelected = selected?.id == character.id
                let canAfford = currentSpirit >= character.cost
                let isOnCooldown = cooldownEndDate.map { Date() < $0 } ?? false
                let isDisabled = !canAfford || isOnCooldown

                CharacterCardUI(
                    character: character,
                    cooldownEndDate: cooldownEndDate,
                    onTap: {
                        guard !isDisabled else { return }

                        if selected?.id == character.id {
                            selected = nil
                        } else {
                            selected = character
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .offset(y: isSelected ? -14 : 0)
                .opacity(canAfford ? 1.0 : 0.45)
                .grayscale(canAfford ? 0 : 0.85)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                .animation(.easeInOut(duration: 0.15), value: canAfford)
                .allowsHitTesting(!isDisabled)
                .gesture(
                    DragGesture(minimumDistance: 4, coordinateSpace: .named(coordSpace))
                        .onChanged { value in
                            guard !isDisabled else { return }

                            selected = character
                            onDragChanged(character, value.location)
                        }
                        .onEnded { value in
                            guard !isDisabled else { return }

                            let placed = onDragEnded(character, value.location)
                            if placed {
                                cooldownEndDates[character.id] = Date().addingTimeInterval(character.cooldownDuration)
                                if selected?.id == character.id {
                                    selected = nil
                                }
                            }
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
