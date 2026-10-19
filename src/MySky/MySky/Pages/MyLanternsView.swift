//
//  MyLanternsView.swift
//  MySky
//
//  Created by Lika Nozadze on 19/10/2026.
//

import SwiftUI
import SwiftData

struct MyLanternsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReleasedLantern.releasedAt, order: .reverse)
    private var lanterns: [ReleasedLantern]

    @State private var selectedLantern: ReleasedLantern?

    var body: some View {
        ZStack {
            SkyBackground()

            GeometryReader { geo in
                ForEach(lanterns) { lantern in
                    Lantern(type: lantern.type,
                            width: 40 * lantern.scale,
                            glowOpacity: 0.6,
                            glowRadius: 20)
                        .goFloating()
                        .onTapGesture { selectedLantern = lantern }   // before .position
                        .position(x: lantern.x * geo.size.width,
                                  y: lantern.y * geo.size.height)
                }
            }

            if lanterns.isEmpty {
                Text("Your released lanterns will glow here")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .sheet(item: $selectedLantern) { lantern in
            LanternDetailView(lantern: lantern) {
                selectedLantern = nil
                modelContext.delete(lantern)
            }
            .presentationDetents([.medium])
        }
    }
}
