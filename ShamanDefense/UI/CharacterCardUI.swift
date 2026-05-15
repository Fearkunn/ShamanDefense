//
//  CharacterCardUI.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct CharacterCardUI: View {
    let character: CharacterData
    var onTap: () -> Void = {}
    @State private var isPressed: Bool = false
    
    var body: some View {
        Image(CharacterSprites.cardImageName(for: character.id))
            .resizable()
            .scaledToFit()
            .scaleEffect(isPressed ? 1.08 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .contentShape(Rectangle())
            .onTapGesture {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
                onTap()
            }
    }
}

#Preview {
    HStack {
        ForEach(GameCollection.allCharacters.prefix(2)) { c in
            CharacterCardUI(character: c)
        }
    }
    .padding()
    .background(Color.green)
}
