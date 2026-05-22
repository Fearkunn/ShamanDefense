//
//  CharacterLabelView.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 11/05/26.
//

import SwiftUI

struct CharacterLabelsView: View {
    let title: String
    let value: String
    let icon: String
    let titleSize: CGFloat
    let valueSize: CGFloat
    private var valueOffsetX: CGFloat { title == "Cost" ? -30 : -25 }

    init(title: String, value: String, icon: String, titleSize: CGFloat = 10, valueSize: CGFloat = 20) {
        self.title = title
        self.value = value
        self.icon = icon
        self.titleSize = titleSize
        self.valueSize = valueSize
    }
    
    var body: some View {
        ZStack {
            Image("icon_board")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .scaleEffect(x: 1.16, y: 1.15, anchor: .leading)
                .scaleEffect(x: 1.7, y: 1.0, anchor: .trailing)

            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 40, height: 40)
                        .offset(x: -10)

                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .rotationEffect(.degrees(icon == "icon_cooldown" ? 18 : 0))
                        .offset(x: -10)
                }

                Text(title)
                    .font(.custom("Montserrat", size: titleSize))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.78))
                    .frame(width: 56, alignment: .leading)
                    .lineLimit(2)
                    .offset(x:-10)

                Spacer(minLength: 0)

                Text(value)
                    .font(.custom("Montserrat", size: valueSize))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.45)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .layoutPriority(2)
                    .frame(minWidth: 38, maxWidth: 64, alignment: .trailing)
                    .offset(x: valueOffsetX)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

extension CharacterData {
    var rangeLabel: String {
        guard kind == .tower, let range = tower?.range else { return "-" }
        switch range {
        case ..<61:
            return "Long"
        case 61..<91:
            return "Mid"
        default:
            return "Short"
        }
    }
    
    var cooldownLabel: String {
        "\(Int(cooldownDuration))s"
    }
    
    var attackSpeedLabel: String {
        guard kind == .tower, let fireInterval = tower?.fireInterval else { return "-" }
        if fireInterval > 1.3 {
            return "Slow"
        } else if fireInterval > 0.8 {
            return "Mid"
        } else {
            return "Fast"
        }
    }
    
    var durationLabel: String {
        switch id {
        case .yayang: return "5s"
        case .yuyul: return "6s"
        default: return "5s"
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        CharacterLabelsView(title: "Cost", value: "300", icon: "dollarsign.circle.fill")
    }
    .padding()
    .background(Color.black)
}
