//
//  StateMachineComponent.swift
//  ShamanDefense
//

import GameplayKit

final class StateMachineComponent: GKComponent {
    let stateMachine: GKStateMachine
    private let states: [GKState]
    private let initialState: AnyClass

    init(states: [GKState], initialState: AnyClass) {
        self.states = states
        self.stateMachine = GKStateMachine(states: states)
        self.initialState = initialState
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func didAddToEntity() {
        for state in states {
            if let entityAware = state as? EntityAwareState {
                entityAware.entity = entity as? GameEntity
            }
        }
        stateMachine.enter(initialState)
    }

    override func update(deltaTime seconds: TimeInterval) {
        stateMachine.update(deltaTime: seconds)
    }
}

protocol EntityAwareState: AnyObject {
    var entity: GameEntity? { get set }
}

class GameState: GKState, EntityAwareState {
    weak var entity: GameEntity?
}
