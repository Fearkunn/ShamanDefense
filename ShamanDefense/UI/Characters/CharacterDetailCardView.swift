//
//  CharacterDetailCardView.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 11/05/26.
//

import SwiftUI

private struct RibbonPlate: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cut = min(14, rect.height * 0.35)
        path.move(to: CGPoint(x: cut, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CharacterDetailCardView: View {
    let selectedCharacter: CharacterData
    
    var body: some View {
        VStack(spacing: 20) {
            nameCard
            
            ScrollView(showsIndicators: false) {
                Text(selectedCharacter.description)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .center)
            }
            .frame(height: 88)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.18)))
            
            if selectedCharacter.kind == .trap {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        CharacterLabelsView(title: "Duration", value: selectedCharacter.durationLabel, icon: "clock.arrow.circlepath")
                        CharacterLabelsView(title: "Cost", value: "\(selectedCharacter.cost * 100)", icon: "dollarsign.circle.fill")
                    }
                    trapPreviewBox
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 320, alignment: .top)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    previewBox
                    
                    VStack(spacing: 9) {
                        CharacterLabelsView(title: "Cost", value: "\(selectedCharacter.cost * 100)", icon: "dollarsign.circle.fill")
                        CharacterLabelsView(title: "Range", value: selectedCharacter.rangeLabel, icon: "scope")
                        CharacterLabelsView(title: "Attack Speed", value: selectedCharacter.attackSpeedLabel, icon: "speedometer")
                        CharacterLabelsView(title: "Cooldown", value: selectedCharacter.cooldownLabel, icon: "clock.fill")
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 320, alignment: .top)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
    
    private var nameCard: some View {
        VStack(spacing: 8) {
            RibbonPlate()
                .fill(Color.white.opacity(0.16))
                .frame(height: 56)
                .overlay(
                    RibbonPlate()
                        .stroke(Color.white.opacity(0.35), lineWidth: 4.0)
                )
                .overlay {
                    Text(selectedCharacter.name.uppercased())
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                }
            
            RibbonPlate()
                .fill(Color.white.opacity(0.16))
                .frame(width: 260, height: 38)
                .overlay(
                    RibbonPlate()
                        .stroke(Color.white.opacity(0.28), lineWidth: 1.0)
                )
                .overlay {
                    Text(selectedCharacter.kind == .tower ? "TOWER" : "TRAP")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
    
    private var previewBox: some View {
        CharacterVideoPreviewView(character: selectedCharacter)
            .frame(width: 170, height: 287)
    }

    private var trapPreviewBox: some View {
        CharacterVideoPreviewView(character: selectedCharacter)
            .frame(height: 209)
    }
}

#Preview {
    CharacterDetailCardView(
        selectedCharacter: GameCollection.allCharacters[0]
    )
    .padding()
    .background(Color.black)
}
