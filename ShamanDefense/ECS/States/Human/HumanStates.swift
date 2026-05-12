//
//  HumanStates.swift
//  ShamanDefense
//

import GameplayKit

final class HumanWalkingState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Phase 5 will allow Slowed / Frozen / Dying.
        return false
    }
}
