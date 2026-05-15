//
//  WaveWarningBanner.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 13/05/26.
//

import SwiftUI

private let waveBannerGold = Color(red: 0.97, green: 0.78, blue: 0.18)

struct WaveWarningBannerData: Equatable {
    let title: String
    let subtitle: String
}

struct WaveWarningBanner: View {
    let data: WaveWarningBannerData
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .frame(height: 90)
            
            HStack(spacing: 0) {
                Color.clear.frame(width: 14)
                PolygonSide()
                    .fill(waveBannerGold)
                    .frame(width: 52, height: 58)
                Rectangle()
                    .fill(waveBannerGold)
                    .frame(height: 58)
                PolygonSide()
                    .fill(waveBannerGold)
                    .frame(width: 52, height: 58)
                    .scaleEffect(x: -1, y: 1)
                Color.clear.frame(width: 14)
            }
            .shadow(color: Color.yellow.opacity(0.55), radius: 16)
            
            VStack(spacing: 2) {
                Text(data.title.uppercased())
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                
                if !data.subtitle.isEmpty {
                    Text(data.subtitle.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: 390)
    }
}

private struct PolygonSide: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WaveWarningBanner(
            data: WaveWarningBannerData(
                title: "WAVE 3 INCOMING...",
                subtitle: "Prepare your defenses!"
            )
        )
    }
}
