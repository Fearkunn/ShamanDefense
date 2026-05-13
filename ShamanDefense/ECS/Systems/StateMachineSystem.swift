//
//  StateMachineSystem.swift
//  ShamanDefense
//

import GameplayKit

final class StateMachineSystem: ComponentSystem<StateMachineComponent> {

    override func add(_ entity: GameEntity) {
        super.add(entity)
        guard let sm = entity.component(ofType: StateMachineComponent.self) else { return }
        for state in sm.states {
            if let aware = state as? EntityAwareState {
                aware.entity = entity
            }
        }
        sm.stateMachine.enter(sm.initialState)
        sm.didEnterInitial = true
    }

    override func update(deltaTime: TimeInterval) {
        for sm in components {
            guard sm.didEnterInitial else { continue }
            sm.stateMachine.update(deltaTime: deltaTime)
        }
    }
}
