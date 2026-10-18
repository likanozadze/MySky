//
//  Lantern.swift
//  MySky
//
//  Created by Mattia Silvestro on 17/10/2026.
//

// ------------------------------------------------------------------------------------
// Our shared definition of how a lantern is drawn with the image and its glow.
// We can use it on any page with:
//
// Lantern(type: .lanternYellow)
//
// OR if you want a different size or a softer glow, you can specify the parameters in the parenthesis:
// Lantern(type: .lanternRed, width: 80, glowOpacity: 0.5, glowRadius: 30)
//
// To make it float, add .goFloating() (see FloatingModifier.swift):
// Lantern(type: .lanternYellow)
//     .goFloating()
// ------------------------------------------------------------------------------------

import SwiftUI

// The 4 lantern types, each one with its image and matching glow color
enum LanternType: CaseIterable {
    case lanternYellow, lanternRed, lanternBlue, lanternPink

    var imageName: String {
        switch self {
        case .lanternYellow: "YellowLantern"
        case .lanternRed:    "RedLantern"
        case .lanternBlue:   "BlueLantern"
        case .lanternPink:   "PinkLantern"
        }
    }

    var glowColor: Color {
        switch self {
        case .lanternYellow: .orange
        case .lanternRed:    .red
        case .lanternBlue:   .cyan
        case .lanternPink:   .pink
        }
    }
}

// Default lantern settings, the same for every type
enum LanternSettings {
    static let width: CGFloat = 130
    static let glowOpacity: Double = 1.0
    static let glowRadius: CGFloat = 60
}

struct Lantern: View {
    let type: LanternType

    // Optional, if we don't pass them the ones from LanternSettings are used
    var isLit: Bool = false // 0 = dimmed (no fire), 1 = lit (fire + glow)
    var width: CGFloat = LanternSettings.width
    var glowOpacity: Double = LanternSettings.glowOpacity // 0 = no glow, 1 = full glow
    var glowRadius: CGFloat = LanternSettings.glowRadius  // how far the glow spreads

    var body: some View {
        Image(isLit ? type.imageName : "\(type.imageName)Dimmed")
            .resizable()
            .scaledToFit()
            .frame(width: width)
            // Glow around the lantern, in the lantern's own color
            .shadow(
                color: type.glowColor.opacity(glowOpacity),
                radius: glowRadius
            )
            .animation(.easeInOut(duration: 0.5), value: isLit)
    }
}

// Shows all 4 lanterns, so we can check how they look
#Preview {
    ZStack {
        SkyBackground()

        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 60) {
            ForEach(LanternType.allCases, id: \.self) { type in
                Lantern(type: type, width: 80)
                    .goFloating()
            }
        }
    }
}
