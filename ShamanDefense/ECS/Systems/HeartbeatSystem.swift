//
//  HeartbeatSystem.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 20/05/26.
//

import Foundation
import UIKit
import GameplayKit
import SpriteKit

final class HeartbeatSystem: GameSystem {

    weak var scene: GameScene?

    private var timer: TimeInterval = 0

    private let triggerDistance: CGFloat = 180

    private let minInterval: TimeInterval = 0.18
    private let maxInterval: TimeInterval = 0.95

    init(scene: GameScene? = nil) {
        self.scene = scene
    }

    func add(_ entity: GameEntity) {}

    func remove(_ entity: GameEntity) {}

    func update(deltaTime: TimeInterval) {

        guard let scene else { return }
        guard !scene.isGameOver else { return }

        timer -= deltaTime

        if timer > 0 {
            return
        }

        var closestProgress: CGFloat = 0

        for human in scene.registry.humans {

            guard let follow =
                human.component(ofType: PathFollowComponent.self)
            else { continue }

            let total =
                CGFloat(max(follow.waypoints.count - 1, 1))

            let current =
                CGFloat(follow.segmentIndex)

            let progress = current / total

            closestProgress = max(
                closestProgress,
                progress
            )
        }

        guard closestProgress > 0.55 else {
            return
        }

        let danger =
            (closestProgress - 0.55) / 0.45

        timer =
            maxInterval -
            (maxInterval - minInterval) * Double(danger)

        triggerHeartbeat(closeness: danger)
    }

    private func triggerHeartbeat(
        closeness: CGFloat
    ) {

        HapticManager.shared.impact(
            .heavy,
            intensity: max(0.75, closeness)
        )

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.085
        ) {

            HapticManager.shared.impact(
                .heavy,
                intensity: max(
                    0.65,
                    closeness * 0.9
                )
            )
        }
    }
}
