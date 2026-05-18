//
//  CharacterVideoPreviewView.swift
//  ShamanDefense
//
//  Created by Jessica Laurentia Tedja on 13/05/26.
//

import SwiftUI
import AVKit

struct CharacterVideoPreviewView: View {
    let character: CharacterData
    var rotateContentDegrees: Double = 0
    var overlayCounterRotationDegrees: Double = 0
    
    @State private var player: AVPlayer?
    @State private var hasVideo = false
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            if !hasVideo {
                Image("video_play")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .rotationEffect(.degrees(rotateContentDegrees))
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                    .rotationEffect(.degrees(overlayCounterRotationDegrees))
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.18))
            }
            
            if let player, hasVideo {
                VideoPlayer(player: player)
                    .rotationEffect(.degrees(rotateContentDegrees))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                EmptyView()
            }
            
            if hasVideo {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            togglePlayPause()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .rotationEffect(.degrees(overlayCounterRotationDegrees))
                        }
                        .padding(10)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            configurePlayer()
        }
        .onChange(of: character.id) { _ in
            configurePlayer()
        }
        .onDisappear {
            player?.pause()
            isPlaying = false
        }
    }
    
    private func configurePlayer() {
        player?.pause()
        isPlaying = false
        hasVideo = false
        player = nil
        
        // Penamaan Video
        // let fileName: String = switch character.id {
        //  case .keti: "ghost_keti"
        //  case .poci: "ghost_poci"
        //  case .gugun: "ghost_gugun"
        //  case .yayang: "ghost_yayang"
        //  case .yuyul: "ghost_yuyul"
    
        let fileName = character.id.rawValue
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") else {
            return
        }
        
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .none
        player = newPlayer
        hasVideo = true
    }
    
    private func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
}

#Preview {
    CharacterVideoPreviewView(character: GameCollection.allCharacters[0])
        .frame(width: 180, height: 260)
        .padding()
        .background(Color.black)
}
