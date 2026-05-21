//
//  SoundManager.swift
//  ShamanDefense
//

import SpriteKit
import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var bgmPlayer: AVAudioPlayer?
    private var activeSFXPlayers: [AVAudioPlayer] = []
    private var sfxVolume: Float = 1.0
    
    private init() {}
    
    func playSFX(
        _ name: String,
        on node: SKNode,
        wait: Bool = false
    ) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
                    print("SFX not found:", name)
                    return
                }
                guard let player = try? AVAudioPlayer(contentsOf: url) else { return }

                player.volume = sfxVolume
                player.play()

                // Simpan referensi agar tidak langsung di-deallocate, bersihkan yang sudah selesai
                activeSFXPlayers.removeAll { !$0.isPlaying }
                activeSFXPlayers.append(player)
            }

    func playBGM(
        _ name: String,
        volume: Float = 0.5
    ) {
        
        if bgmPlayer?.isPlaying == true {
            return
        }
        
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: nil
        ) else {
            print("BGM not found:", name)
            return
        }
        
        do {
            
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = volume
            
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
            
        } catch {
            
            print("Failed to play BGM:", error)
        }
    }
    
    func setBGMVolume(_ volume: Float) {
        bgmPlayer?.volume = max(0, min(1, volume))
    }
    
    func setSFXVolume(_ volume: Float) {
        sfxVolume = max(0, min(1, volume))
    }

}
