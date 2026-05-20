//
//  WaveWarningBanner.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 13/05/26.
//

import SwiftUI

struct WaveWarningBannerData: Equatable {
    let title: String
}

struct WaveWarningBanner: View {
    let data: WaveWarningBannerData
    
    var body: some View {
        ZStack {
            Image("button")
                .resizable()
                .frame(height: 65)
                .frame(width: 300)

            if !data.title.isEmpty {
                Text(data.title)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#A52525"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Image("warning")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .offset(y: -50)
        }
        .frame(maxWidth: 360)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WaveWarningBanner(
            data: WaveWarningBannerData(
                title: "WAVE 3 INCOMING...",
            )
        )
    }
}
