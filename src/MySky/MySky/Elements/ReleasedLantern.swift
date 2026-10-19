//
//  ReleasedLantern.swift
//  MySky
//
//  Created by Lika Nozadze on 19/10/2026.
//

import SwiftData
import Foundation

@Model
final class ReleasedLantern {
    var id: UUID = UUID()
    var typeRaw: String = LanternType.lanternYellow.rawValue
    var wish: String = ""
    var releasedAt: Date = Date()
    
    var x: Double = 0.5
    var y: Double = 0.5
    var scale: Double = 1.0

    var type: LanternType { LanternType(rawValue: typeRaw) ?? .lanternYellow }

    init(type: LanternType, wish: String) {
        self.typeRaw = type.rawValue
        self.wish = wish
        self.x = .random(in: 0.1...0.9)
        self.y = .random(in: 0.1...0.8)
        self.scale = .random(in: 0.6...1.4)
    }
}
