//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct LanternView: View {

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            SkyBackground()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("What do you want to\n wish for?")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach([LanternType.lanternRed, .lanternYellow, .lanternBlue, .lanternPink], id: \.self) { type in
                        NavigationLink(destination: WriteWishView(selectedLanternType: type)) {
                            LanternCard(type: type, title: type.title)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 25)

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        LanternView()
    }
}
