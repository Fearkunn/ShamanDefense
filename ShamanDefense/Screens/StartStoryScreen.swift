//
//  StartStoryScreen.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 13/05/26.
//

import SwiftUI

private extension View {
    func storyTextStyle() -> some View {
        self
            .font(.system(.body, design: .rounded).weight(.medium))
            .foregroundStyle(.black.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
}

struct StartStoryScreen: View {
    let onFinish: () -> Void
    
    @State private var pageIndex = 0
    @State private var visibleCharacterCount = 0
    
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
        "Now, the villagers are coming to destroy your house — summon the spirits and protect yourself before they reach you."
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
                
                VStack(spacing: 14) {
                    Text(typedStoryText)
                        .storyTextStyle()
                    
                    
                    if isLastPage {
                        startDefendingButton
                            .opacity(isTypingCompleted ? 1 : 0)
                            .padding(.bottom, 16)
                    } else {
                        Color.clear
                            .frame(height: 8)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 170, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                if !isLastPage && isTypingCompleted {
                    Text("TAP ANYWHERE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 56)
                } else {
                    Color.clear
                        .frame(height: 56)
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
        Button("START DEFENDING!") {
            onFinish()
        }
        .font(.system(size: 18, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(Capsule(style: .continuous).fill(Color.black))
        .buttonStyle(.plain)
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
