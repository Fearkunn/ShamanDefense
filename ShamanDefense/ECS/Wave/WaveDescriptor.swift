//
//  WaveDescriptor.swift
//  ShamanDefense
//

import Foundation
import CoreGraphics
import GameplayKit

struct SpawnEntry {
    let archetype: HumanArchetype
    let delayAfterPrevious: TimeInterval
}

struct SpawnGroup {
    let archetype: HumanArchetype
    let count: Int
    let startOffset: TimeInterval
}

struct WaveDescriptor {
    let waveNumber: Int
    let entries: [SpawnEntry]

    static func generate(wave: Int, config: WaveScalingConfig) -> WaveDescriptor {
        let totalCount = config.count(for: wave)
        let weights = config.archetypeWeights(for: wave)
        let rng = GKMersenneTwisterRandomSource(seed: UInt64(wave &* 2654435761))

        let groups = buildGroups(totalCount: totalCount,
                                 weights: weights,
                                 maxStartOffset: config.maxGroupStartOffset,
                                 rng: rng)

        let timeline = mergeTimelines(groups: groups,
                                      jitter: config.jitterFraction,
                                      rng: rng)

        return WaveDescriptor(waveNumber: wave, entries: timeline)
    }

    private static func buildGroups(totalCount: Int,
                                    weights: [(HumanArchetype, Double)],
                                    maxStartOffset: TimeInterval,
                                    rng: GKMersenneTwisterRandomSource) -> [SpawnGroup] {
        guard !weights.isEmpty else { return [] }
        let totalWeight = weights.reduce(0.0) { $0 + $1.1 }

        var groups: [SpawnGroup] = []
        var allocated = 0
        for (i, (arch, w)) in weights.enumerated() {
            let isLast = i == weights.count - 1
            let count: Int
            if isLast {
                count = max(0, totalCount - allocated)
            } else {
                count = Int((Double(totalCount) * w / totalWeight).rounded())
            }
            allocated += count
            guard count > 0 else { continue }

            let offset = i == 0 ? 0 : Double(rng.nextUniform()) * maxStartOffset
            groups.append(SpawnGroup(archetype: arch, count: count, startOffset: offset))
        }
        return groups
    }

    private static func mergeTimelines(groups: [SpawnGroup],
                                       jitter: Double,
                                       rng: GKMersenneTwisterRandomSource) -> [SpawnEntry] {
        struct Stamped { let time: TimeInterval; let archetype: HumanArchetype }
        var stamps: [Stamped] = []

        for group in groups {
            var t = group.startOffset
            for i in 0..<group.count {
                if i > 0 {
                    let gap = group.archetype.baseSpawnGap
                    let jitterAmt = (Double(rng.nextUniform()) * 2 - 1) * jitter
                    t += gap * (1 + jitterAmt)
                }
                stamps.append(Stamped(time: t, archetype: group.archetype))
            }
        }

        stamps.sort { $0.time < $1.time }

        var entries: [SpawnEntry] = []
        entries.reserveCapacity(stamps.count)
        var prev: TimeInterval = 0
        for (i, s) in stamps.enumerated() {
            let delay = i == 0 ? s.time : max(0, s.time - prev)
            entries.append(SpawnEntry(archetype: s.archetype, delayAfterPrevious: delay))
            prev = s.time
        }
        return entries
    }
}
