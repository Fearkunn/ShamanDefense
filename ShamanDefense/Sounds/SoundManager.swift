//
//  SoundManager.swift
//  ShamanDefense
//

import SpriteKit
import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var bgmPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playSFX(
        _ name: String,
        on node: SKNode,
        wait: Bool = false
    ) {
        node.run(
            .playSoundFileNamed(
                name,
                waitForCompletion: wait
            )
        )
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
        bgmPlayer?.volume = volume
    }
}
