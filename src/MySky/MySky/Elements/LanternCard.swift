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
                    floatX: 2,
                    floatY: 6,
                    tilt: 2,
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
        .background(RoundedRectangle(cornerRadius: 28)
            .fill(.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .blur(radius: 10)
            )
            
        )
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
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
