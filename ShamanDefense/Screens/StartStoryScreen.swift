//
//  StartStoryScreen.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 13/05/26.
//

import SwiftUI

private extension View {
    var storyTextColor: Color { Color(hex: "#4B4B4B") }

    func storyTextStyle() -> some View {
        self
            .font(.custom("Montserrat", size: 14))
            .fontWeight(.bold)
            .foregroundStyle(storyTextColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
}

struct StartStoryScreen: View {
    let onFinish: () -> Void
    
    @State private var pageIndex = 0
    @State private var visibleCharacterCount = 0
    @State private var isStartButtonPulsing = false
    
    private var isLastPage: Bool {
        pageIndex == storyPages.count - 1
    }
    
    
    private var currentStoryCharacters: [Character] {
        Array(storyPages[pageIndex])
    }
    
    private var isTypingCompleted: Bool {
        visibleCharacterCount >= currentStoryCharacters.count
    }
    
    private var typedStoryText: String {
        String(currentStoryCharacters.prefix(visibleCharacterCount))
    }
    
    private let storyPages: [String] = [
        "You are a shaman living deep in the forest, performing rituals and communicating with wandering spirits.",
        "Now, the villagers are coming to approach you — summon the spirits and protect yourself before they reach you."
    ]
    
    var body: some View {
        ZStack {
            Image("map")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text(typedStoryText)
                        .storyTextStyle()
                }
                .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 170, alignment: .center)
                .background(
                    Image(pageIndex == 0 ? "bg_story_1" : "bg_story_2")
                        .resizable()
                        .scaledToFit()
                )
                .padding(.horizontal, 24)

                if isLastPage {
                    startDefendingButton
                        .opacity(isTypingCompleted ? 1 : 0)
                }
                
                Spacer()
                
                if !isLastPage && isTypingCompleted {
                    Text("TAP ANYWHERE!")
                        .font(.custom("Montserrat", size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.bottom, 72)
                } else {
                    Color.clear
                        .frame(height: 72)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isTypingCompleted {
                return
            }
            
            if !isLastPage {
                withAnimation(.easeInOut(duration: 0.2)) {
                    pageIndex += 1
                }
            }
        }
        .task(id: pageIndex) {
            await typeCurrentStoryText()
        }
    }
    
    private var startDefendingButton: some View {
        Button {
            onFinish()
        }
        label: {
            Image("button_startdefending")
                .resizable()
                .scaledToFit()
                .frame(width: 210)
                .scaleEffect(isStartButtonPulsing ? 1.07 : 0.96)
                .animation(
                    .easeInOut(duration: 0.4).repeatForever(autoreverses: true),
                    value: isStartButtonPulsing
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            isStartButtonPulsing = true
        }
    }
    
    private func typeCurrentStoryText() async {
        visibleCharacterCount = 0
        let total = currentStoryCharacters.count
        guard total > 0 else { return }
        
        for index in 1...total {
            visibleCharacterCount = index
            try? await Task.sleep(nanoseconds: 70_000_000)
        }
    }
}

#Preview {
    StartStoryScreen(onFinish: {})
}
