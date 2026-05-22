//
//  SoundManager.swift
//  ShamanDefense
//

import SpriteKit
import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPools: [String: [AVAudioPlayer]] = [:]
    private var sfxVolume: Float = 1.0
    private let poolSize = 4

    private init() {}

    func preload(_ names: [String]) {
        for name in names where sfxPools[name] == nil {
            guard let url = Bundle.main.url(forResource: name, withExtension: nil),
                  let data = try? Data(contentsOf: url) else {
                print("SFX not found:", name)
                continue
            }
            var players: [AVAudioPlayer] = []
            players.reserveCapacity(poolSize)
            for _ in 0..<poolSize {
                guard let p = try? AVAudioPlayer(data: data) else { continue }
                p.volume = sfxVolume
                p.prepareToPlay()
                players.append(p)
            }
            sfxPools[name] = players
        }
    }

    func playSFX(
        _ name: String,
        on node: SKNode,
        wait: Bool = false
    ) {
        playPooled(name)
    }

    func playUISFX(_ name: String) {
        playPooled(name)
    }

    private func playPooled(_ name: String) {
        if let pool = sfxPools[name],
           let player = pool.first(where: { !$0.isPlaying }) {
            player.volume = sfxVolume
            player.currentTime = 0
            player.play()
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let player = try? AVAudioPlayer(data: data) else {
            print("SFX not found:", name)
            return
        }
        player.volume = sfxVolume
        player.prepareToPlay()
        player.play()
        sfxPools[name, default: []].append(player)
    }

    func playBGM(
        _ name: String,
        volume: Float = 0.5
    ) {
        if bgmPlayer?.isPlaying == true {
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
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
        for pool in sfxPools.values {
            for player in pool {
                player.volume = sfxVolume
            }
        }
    }

    func fadeBGM(
        to volume: Float,
        duration: TimeInterval = 0.5
    ) {
        guard let player = bgmPlayer else {
            return
        }
        let startVolume = player.volume
        let steps = 20
        for step in 0...steps {
            let delay = duration / Double(steps) * Double(step)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let progress = Float(step) / Float(steps)
                player.volume = startVolume + (volume - startVolume) * progress
            }
        }
    }
}
