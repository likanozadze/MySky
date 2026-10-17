//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//


import SwiftUI

struct LanternCard: View {

    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 82)

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
            imageName: "RedLantern",
            title: "Health"
        )
        .padding(40)
    }
}
