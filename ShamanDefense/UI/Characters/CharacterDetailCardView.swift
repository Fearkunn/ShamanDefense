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
    private let primaryTextColor = Color(hex: "#4B4B4B")
    
    private var balancedDescription: String {
        let words = selectedCharacter.description.split(separator: " ")
        guard words.count > 3 else { return selectedCharacter.description }
        
        if selectedCharacter.id == .yayang || selectedCharacter.id == .poci {
            let firstBreak = words.count / 3
            let secondBreak = (words.count * 2) / 3
            let line1 = words[..<firstBreak].joined(separator: " ")
            let line2 = words[firstBreak..<secondBreak].joined(separator: " ")
            let line3 = words[secondBreak...].joined(separator: " ")
            return line1 + "\n" + line2 + "\n" + line3
        }
        
        let midpoint = words.count / 2
        let firstLine = words[..<midpoint].joined(separator: " ")
        let secondLine = words[midpoint...].joined(separator: " ")
        return firstLine + "\n" + secondLine
    }
    
    var body: some View {
        VStack(spacing: 8) {
            nameCard
                .offset(y: -8)
            
            ZStack {
                Image("button_character")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Text(balancedDescription)
                    .font(.custom("Montserrat", size: 15))
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 110)
            .offset(y: -50)
            
            ZStack {
                Image("board_character")
                    .resizable()
                    .scaledToFill()
                    .rotationEffect(.degrees(90))
                    .scaleEffect(0.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .offset(y: -30)
                
                if selectedCharacter.kind == .trap {
                    HStack(alignment: .top, spacing: 12) {
                        trapPreviewBox

                        VStack(spacing: 15) {
                            CharacterLabelsView(title: "Cost", value: "\(selectedCharacter.cost * 100)", icon: "icon_ghost")
                                .offset(x: -180)
                            CharacterLabelsView(title: "Duration", value: selectedCharacter.durationLabel, icon: "icon_cooldown")
                                .offset(y: -65)
                        }
                        .frame(maxWidth: .infinity)
                        .offset(y: -20)
                    }
                    .frame(height: 274, alignment: .top)
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        previewBox
                        
                        VStack(spacing: 15) {
                            CharacterLabelsView(title: "Cost", value: "\(selectedCharacter.cost * 100)", icon: "icon_ghost")
                            CharacterLabelsView(title: "Range", value: selectedCharacter.rangeLabel, icon: "icon_range")
                            CharacterLabelsView(title: "Attack Speed", value: selectedCharacter.attackSpeedLabel, icon: "icon_attack")
                            CharacterLabelsView(title: "Cooldown", value: selectedCharacter.cooldownLabel, icon: "icon_cooldown")
                        }
                        .frame(maxWidth: .infinity)
                        .offset(y: -20)
                    }
                    .frame(height: 274, alignment: .top)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .frame(height: 300)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
    
    private var nameCard: some View {
        VStack(spacing: 8) {
            Image("board")
                .resizable()
                .scaledToFit()
                .frame(height: 144)
                .overlay(alignment: .center) {
                    VStack(spacing: 0) {
                        Text(selectedCharacter.name.uppercased())
                            .font(.custom("Newyear Coffee", size: 30))
                            .fontWeight(.semibold)
                            .foregroundStyle(primaryTextColor)
                        
                        Text(selectedCharacter.kind == .tower ? "Tower" : "Trap")
                            .font(.custom("Montserrat", size: 17))
                            .fontWeight(.bold)
                            .foregroundStyle(primaryTextColor)
                    }
                    .offset(x: 0, y: -24)
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
    
    private var previewBox: some View {
        CharacterVideoPreviewView(character: selectedCharacter)
            .frame(width: 220, height: 360)
            .offset(y: -80)
    }
    
    private var trapPreviewBox: some View {
        CharacterVideoPreviewView(
            character: selectedCharacter,
            rotateContentDegrees: 0,
            overlayCounterRotationDegrees: -90
        )
            .frame(width: 220, height: 440)
            .offset(x: -80, y: -112)
            .rotationEffect(.degrees(90))

    }
}

#Preview {
    CharacterDetailCardView(
        selectedCharacter: GameCollection.allCharacters[0]
    )
    .padding()
    .background(Color.black)
}
