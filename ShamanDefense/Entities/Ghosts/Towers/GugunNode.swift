//
//  GugunNode.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit

final class GugunNode: GhostNode {
    init() { super.init(displayName: "Gugun", fillColor: .yellow) }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
