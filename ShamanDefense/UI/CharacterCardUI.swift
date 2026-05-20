//
//  CharacterCardUI.swift
//  ShamanDefense
//
//  Created by Mohammad Rizaldy Ramadhan on 06/05/26.
//

import SwiftUI

struct CharacterCardUI: View {
    let character: CharacterData
    var cooldownEndDate: Date? = nil
    var onTap: () -> Void = {}
    @State private var isPressed: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(CharacterSprites.cardImageName(for: character.id))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            HStack(spacing: 2) {
                Image("ghost_currency")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14)
                Text("\(character.cost)")
                    .font(.custom("Newyear Coffee", size: 20))
                    .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
            }
            .padding(.bottom, 4)
        }
        .overlay {
            if let endDate = cooldownEndDate {
                TimelineView(.animation) { context in
                    let now = context.date
                    let remaining = max(0, endDate.timeIntervalSince(now))
                    let total = character.cooldownDuration
                    let fraction = total > 0 ? remaining / total : 0
                    
                    if remaining > 0 {
                        ZStack {
                            // Dark glassmorphic background overlay
                            Color.black.opacity(0.65)
                            
                            // Circular sweep timer
                            Circle()
                                .trim(from: 0, to: fraction)
                                .stroke(
                                    LinearGradient(
                                        colors: [.orange, .red, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 44, height: 44)
                            
                            // Remaining time text
                            Text(String(format: "%.1fs", remaining))
                                .font(.custom("Newyear Coffee", size: 14))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isPressed ? 1.08 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            // Check if card is on cooldown to prevent press animation and tap
            let isOnCooldown = cooldownEndDate.map { $0 > Date() } ?? false
            guard !isOnCooldown else { return }
            
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
