//
//  CharacterCardUI.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct CharacterCardUI: View {
    let character: CharacterData
    var isSelected: Bool = false
    var onTap: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(character.tint)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black, lineWidth: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )

            VStack(spacing: 4) {
                Spacer(minLength: 8)
                Image(systemName: character.symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, y: 1)
                Spacer(minLength: 2)
                Text(character.name)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 1, y: 1)
                    .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity)

            ZStack {
                Circle()
                    .fill(Color.purple)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                Text("\(character.cost)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 22, height: 22)
            .offset(x: -6, y: -6)
        }
        .frame(width: 70, height: 90)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
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
