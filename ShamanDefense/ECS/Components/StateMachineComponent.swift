//
//  StateMachineComponent.swift
//  ShamanDefense
//

import GameplayKit

final class StateMachineComponent: GKComponent {
    let stateMachine: GKStateMachine
    let states: [GKState]
    let initialState: AnyClass
    var didEnterInitial: Bool = false

    init(states: [GKState], initialState: AnyClass) {
        self.states = states
        self.stateMachine = GKStateMachine(states: states)
        self.initialState = initialState
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

protocol EntityAwareState: AnyObject {
    var entity: GameEntity? { get set }
}

class GameState: GKState, EntityAwareState {
    weak var entity: GameEntity?
}
