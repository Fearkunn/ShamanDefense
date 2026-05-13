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
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.yellow.opacity(0.95))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.16))
        )
    }
}

extension CharacterData {
    var rangeLabel: String {
        kind == .tower ? "Mid" : "Short"
    }
    
    var cooldownLabel: String {
        switch kind {
        case .tower: return "4s"
        case .trap: return "6s"
        }
    }
    
    var attackSpeedLabel: String {
        switch kind {
        case .tower: return "Low"
        case .trap: return "Mid"
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
