//
//  TeamComponent.swift
//  ShamanDefense
//

import GameplayKit

enum Team {
    case ghost
    case human
}

final class TeamComponent: GKComponent {
    let team: Team

    init(team: Team) {
        self.team = team
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
