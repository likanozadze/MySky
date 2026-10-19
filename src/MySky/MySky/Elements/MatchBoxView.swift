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

    var body: some View {
        ZStack {
            Image("Matchbox")
                .resizable()
                .scaledToFit()
                .opacity(isOpened ? 0 : 1)
            
            Image("OpenedMatchBox")
                .resizable()
                .scaledToFit()
                .opacity(isOpened ? 1 : 0)
        }
        .frame(width: width)
        .scaleEffect(isOpened ? 1.1 : 1.0)
        .onTapGesture {
            guard !isOpened else {
                onTapWhenOpened()
                return
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                isOpened = true
            }
        }
    }
}

#Preview {
    MatchboxView(isOpened: .constant(false))
}
