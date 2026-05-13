//
//  TrapStates.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

class TrapArmedState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is TrapTriggeredState.Type
            || stateClass == YayangTriggeredState.self
            || stateClass == YuyulTriggeredState.self
    }
}

class TrapTriggeredState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == TrapSpentState.self
    }
}

final class TrapSpentState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool { false }

    override func didEnter(from previousState: GKState?) {
        guard let entity,
              let scene = entity.component(ofType: SpriteComponent.self)?.node.scene as? GameScene else { return }
        let sprite = entity.component(ofType: SpriteComponent.self)
        sprite?.node.run(.sequence([
            .fadeOut(withDuration: 0.4),
            .run { [weak scene, weak entity] in
                guard let scene, let entity else { return }
                scene.removeEntity(entity)
            }
        ]))
    }
}

final class YayangTriggeredState: TrapTriggeredState {
    override func didEnter(from previousState: GKState?) {
        guard let entity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let scene = sprite.node.scene as? GameScene,
              let aura = entity.component(ofType: FreezeAuraComponent.self) else { return }

        let pulse = SKShapeNode(circleOfRadius: 40)
        pulse.position = sprite.position
        pulse.fillColor = SKColor.cyan.withAlphaComponent(0.25)
        pulse.strokeColor = .cyan
        pulse.lineWidth = 2
        pulse.zPosition = 4
        scene.fxLayer.addChild(pulse)
        pulse.run(.sequence([
            .group([.scale(to: 12, duration: 0.5), .fadeOut(withDuration: 0.5)]),
            .removeFromParent()
        ]))

        aura.detonate(in: scene.registry)
        stateMachine?.enter(TrapSpentState.self)
    }
}

final class YuyulTriggeredState: TrapTriggeredState {
    override func didEnter(from previousState: GKState?) {
        guard let entity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let scene = sprite.node.scene as? GameScene,
              let runner = entity.component(ofType: PathRunnerComponent.self),
              let aura = entity.component(ofType: SlowAuraComponent.self) else { return }

        let backwardWaypoints = scene.pathBackward(from: sprite.position)
        runner.configure(waypoints: backwardWaypoints)
        aura.active = true
        runner.active = true
        runner.onComplete = { [weak self] in
            self?.stateMachine?.enter(TrapSpentState.self)
        }
    }

    override func willExit(to nextState: GKState) {
        guard let aura = entity?.component(ofType: SlowAuraComponent.self) else { return }
        aura.active = false
    }
}
