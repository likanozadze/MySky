//
//  Untitled.swift
//  MySky
//
//  Created by Lika Nozadze on 19/10/2026.
//

import SwiftUI

struct LanternDetailView: View {
    let lantern: ReleasedLantern
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            Lantern(type: lantern.type, width: 90)

            Text(lantern.wish.isEmpty ? "No words, just a quiet release." : lantern.wish)
                .font(.system(size: 20, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(lantern.releasedAt.formatted(date: .long, time: .shortened))
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button("Delete lantern", role: .destructive) {
                showDeleteConfirmation = true
            }
            .buttonStyle(.glass)
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkyBackground())
        .confirmationDialog("Delete this lantern?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("This lantern and its wish will be gone for good.")
        }
    }
}
