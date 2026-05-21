//
//  OptionScreen.swift
//  ShamanDefense
//
//  Created by Michael on 18/05/26.
//

import Foundation
import Combine

class OptionViewModel: ObservableObject {
    
    // MARK: - Shared Instance
    // Pakai .shared supaya data selalu sinkron antara MainMenu popup dan Pause screen
    
    static let shared = OptionViewModel()
    
    // MARK: - Properties
    
    @Published var backgroundMusic: Float {
        didSet {
            UserDefaults.standard.set(backgroundMusic, forKey: "backgroundMusic")
            SoundManager.shared.setBGMVolume(backgroundMusic)
        }
    }
    
    @Published var soundEffect: Float {
        didSet {
            UserDefaults.standard.set(soundEffect, forKey: "soundEffect")
            SoundManager.shared.setSFXVolume(soundEffect)
        }
    }
    
    @Published var hapticEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled") }
    }
    
    // MARK: - Init
    
    private init() {
        // Baca dari UserDefaults, default ke 1.0 / true jika belum pernah disimpan
        let music   = UserDefaults.standard.object(forKey: "backgroundMusic") as? Float ?? 1.0
        let sound   = UserDefaults.standard.object(forKey: "soundEffect")    as? Float ?? 1.0
        let haptic  = UserDefaults.standard.object(forKey: "hapticEnabled")  as? Bool  ?? true
        
        self.backgroundMusic = music
        self.soundEffect     = sound
        self.hapticEnabled   = haptic
        
        SoundManager.shared.setBGMVolume(music)
        SoundManager.shared.setSFXVolume(sound)
    }
}
