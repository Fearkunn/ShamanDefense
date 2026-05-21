//
//  GhostAttackExecutor.swift
//  ShamanDefense
//

import SpriteKit

struct GhostAttackContext {
    let scene: GameScene
    let source: GameEntity
    let origin: CGPoint
    let target: GameEntity
    let launcher: ProjectileLauncherComponent
}

protocol GhostAttackExecutor {
    func execute(_ context: GhostAttackContext)
}

enum GhostAttackDispatcher {
    static func executeSpecialIfNeeded(
        style: GhostAttackStyle,
        context: GhostAttackContext
    ) -> Bool {
        
        if let ghostID = context.launcher.sourceGhostID {
            switch ghostID {
            case .keti:
                SoundManager.shared.playSFX(
                    "keti_attack.wav",
                    on: context.scene
                )
            case .poci:
                SoundManager.shared.playSFX(
                    "poci_attack.wav",
                    on: context.scene
                )
            case .gugun:
                SoundManager.shared.playSFX(
                    "gugun_attack.wav",
                    on: context.scene
                )
            default:
                break
            }
        }
        
        switch style {
        case .pociHeadbutt:
            PociAttackExecutor().execute(context)
            return true
            
        case .ketiScream:
            KetiAttackExecutor().execute(context)
            return true
            
        case .gugunJump:
            GugunAttackExecutor().execute(context)
            return true
            
        case .projectile:
            return false
        }
    }
}
