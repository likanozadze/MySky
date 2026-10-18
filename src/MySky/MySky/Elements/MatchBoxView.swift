//
//  matchbox.swift
//  MySky
//
//  Created by Lika Nozadze on 18/10/2026.
//

import SwiftUI

struct MatchboxView: View {
    @Binding var isOpened: Bool
    
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
        .frame(width: 140)
        .scaleEffect(isOpened ? 1.1 : 1.0)
        .onTapGesture {
            guard !isOpened else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                isOpened = true
            }
        }
    }
}

#Preview {
    MatchboxView(isOpened: .constant(false))
}
