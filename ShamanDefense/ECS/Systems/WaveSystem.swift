//
//  WaveSystem.swift
//  ShamanDefense
//

import Foundation
import GameplayKit

final class WaveSystem: ComponentSystem<WaveManagerComponent> {
    override func update(deltaTime: TimeInterval) {
        for mgr in components {
            tick(mgr, dt: deltaTime)
        }
    }

    private func tick(_ mgr: WaveManagerComponent, dt: TimeInterval) {
        switch mgr.state {
        case .stopped:
            return

        case .intermission:
            mgr.stateTimer -= dt
            if mgr.stateTimer <= 0 {
                startNextWave(mgr)
            }

        case .spawning:
            mgr.nextSpawnIn -= dt
            while mgr.nextSpawnIn <= 0 && !mgr.pendingEntries.isEmpty {
                let entry = mgr.pendingEntries.removeFirst()
                mgr.onSpawn?(entry.archetype, mgr.config.globalHpMultiplier(for: mgr.currentWave))
                if let next = mgr.pendingEntries.first {
                    mgr.nextSpawnIn += next.delayAfterPrevious
                } else {
                    mgr.state = .resolving
                }
            }

        case .resolving:
            let alive = mgr.humansAliveCount?() ?? 0
            if alive == 0 {
                mgr.state = .intermission
                mgr.stateTimer = mgr.config.intermission
                mgr.onIntermission?(mgr.currentWave + 1)
            }
        }
    }

    private func startNextWave(_ mgr: WaveManagerComponent) {
        let next = mgr.currentWave + 1
        let descriptor = WaveDescriptor.generate(wave: next, config: mgr.config)
        mgr.currentWave = next
        mgr.pendingEntries = descriptor.entries
        mgr.nextSpawnIn = descriptor.entries.first?.delayAfterPrevious ?? 0
        mgr.state = .spawning
        mgr.onWaveStart?(next)
    }
}
