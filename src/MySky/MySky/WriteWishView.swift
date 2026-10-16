//
//  WriteWishView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct WriteWishView: View {
    let selectedLanternImage: String
    
    @State private var wishText: String = ""
    
    var body: some View {
        ZStack {
            Image("AppBackground2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack (spacing: 40) {
                Spacer()
                
    
                Image(selectedLanternImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)
            
                    .overlay(
                        Text(wishText)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    )
                    .padding(.bottom, 40)
                
                
                VStack(spacing: 8) {
                    TextField("", text: $wishText, prompt:
                        Text("Share your feelings here")
                            .foregroundColor(.white.opacity(0.5))
                    , axis: .vertical)
                    .foregroundColor(.white)
                    .tint(.white)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .lineLimit(1...5)
                
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 60)
                Spacer()
                
            
                Button(action: {
                
                }) {
                    Text("Submit")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .glassEffect(
                            .regular,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    WriteWishView(selectedLanternImage: "YellowLantern")
}
