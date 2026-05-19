//
//  OptionScreen.swift
//  ShamanDefense
//
//  Created by Michael on 18/05/26.
//

import Foundation
import Combine

final class OptionViewModel: ObservableObject {

    @Published var backgroundMusic: Float {
        didSet {
            UserDefaults.standard.set(backgroundMusic, forKey: "backgroundMusic")
        }
    }

    @Published var soundEffect: Float {
        didSet {
            UserDefaults.standard.set(soundEffect, forKey: "soundEffect")
        }
    }

    @Published var hapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
        }
    }

    init() {

        self.backgroundMusic = UserDefaults.standard.object(forKey: "backgroundMusic") as? Float ?? 1.0

        self.soundEffect = UserDefaults.standard.object(forKey: "soundEffect") as? Float ?? 1.0

        self.hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
    }
}
