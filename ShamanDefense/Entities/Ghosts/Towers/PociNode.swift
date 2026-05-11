//
//  PociNode.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SpriteKit

final class PociNode: GhostNode {
    init() { super.init(displayName: "Poci", fillColor: .cyan) }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
