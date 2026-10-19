//
//  matchbox.swift
//  MySky
//
//  Created by Lika Nozadze on 18/10/2026.
//

import SwiftUI

struct MatchboxView: View {
    @Binding var isOpened: Bool
    var width: CGFloat = 140
    // Optional, what happens when we tap the matchbox once it's already open
    var onTapWhenOpened: () -> Void = {}

    // The two images have different sizes (closed 303 x 304, opened 308 x 349),
    // but the box is drawn in the same place, just 45 lower in the opened one (the matches stick out on top).
    // So we draw both at the same scale and move the opened one up by 45, this way the box doesn't jump.
    private var unit: CGFloat { width / 303 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("Matchbox")
                .resizable()
                .frame(width: 303 * unit, height: 304 * unit)
                .opacity(isOpened ? 0 : 1)

            Image("OpenedMatchBox")
                .resizable()
                .frame(width: 308 * unit, height: 349 * unit)
                .offset(y: -45 * unit)
                .opacity(isOpened ? 1 : 0)
        }
        // The size of the view is the closed matchbox, the matches of the opened one go above it
        .frame(width: 303 * unit, height: 304 * unit, alignment: .topLeading)
        .onTapGesture {
            guard !isOpened else {
                onTapWhenOpened()
                return
            }
            withAnimation(.easeInOut(duration: 0.35)) {
                isOpened = true
            }
        }
    }
}

#Preview {
    MatchboxView(isOpened: .constant(false))
}
