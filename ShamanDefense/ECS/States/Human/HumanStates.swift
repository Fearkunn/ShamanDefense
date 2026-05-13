//
//  HumanStates.swift
//  ShamanDefense
//

import GameplayKit

final class HumanWalkingState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == HumanSlowedState.self || stateClass == HumanFrozenState.self
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let effects = entity?.component(ofType: EffectsComponent.self) else { return }
        if effects.isFrozen {
            stateMachine?.enter(HumanFrozenState.self)
        } else if effects.isSlowed {
            stateMachine?.enter(HumanSlowedState.self)
        }
    }
}

final class HumanSlowedState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == HumanWalkingState.self || stateClass == HumanFrozenState.self
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let effects = entity?.component(ofType: EffectsComponent.self) else { return }
        if effects.isFrozen {
            stateMachine?.enter(HumanFrozenState.self)
        } else if !effects.isSlowed {
            stateMachine?.enter(HumanWalkingState.self)
        }
    }
}

final class HumanFrozenState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == HumanWalkingState.self || stateClass == HumanSlowedState.self
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let effects = entity?.component(ofType: EffectsComponent.self) else { return }
        if !effects.isFrozen {
            if effects.isSlowed {
                stateMachine?.enter(HumanSlowedState.self)
            } else {
                stateMachine?.enter(HumanWalkingState.self)
            }
        }
    }
}
