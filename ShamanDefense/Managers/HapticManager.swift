//
//  HapticManager.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 21/05/26.
//

import UIKit

final class HapticManager {

    static let shared = HapticManager()

    private init() {}

    var isEnabled = true

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle,
                intensity: CGFloat = 1.0) {

        guard isEnabled else { return }

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {

        guard isEnabled else { return }

        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {

        guard isEnabled else { return }

        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
