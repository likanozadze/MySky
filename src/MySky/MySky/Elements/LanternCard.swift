//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//


import SwiftUI

struct LanternCard: View {

    let type: LanternType
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Lantern(type: type, width: 82, glowOpacity: 0.5, glowRadius: 30)
                .goFloating(
                    floatX: 4,
                    floatY: 15,
                    tilt: 5,
                    speedX: 1.0,
                    speedY: 1.2,
                    tiltSpeed: 1.0
                )

            Text(title)
                .font(.system(
                    size: 17,
                    weight: .medium,
                    design: .rounded
                ))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 28)
        )
    }
}

#Preview {
    ZStack {
        Image("AppBackground")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        LanternCard(
            type: .lanternRed,
            title: "Health"
        )
        .padding(40)
    }
}
