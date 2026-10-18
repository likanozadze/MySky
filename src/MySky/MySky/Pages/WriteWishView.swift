//
//  WriteWishView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct WriteWishView: View {
    let selectedLanternType: LanternType
    
    @State private var wishText: String = ""
    
    var body: some View {
        ZStack {
            SkyBackground()
            
            VStack (spacing: 24) {
                Spacer()
                
                Lantern(type: selectedLanternType, width: 200)
                    .overlay(
                        Text(wishText)
                            .font(.system(size: 17, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(wishText.isEmpty ? .black.opacity(0.3) : .black.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    )
                    .padding(.bottom, 40)
                
                Spacer()
                
                TextField("", text: $wishText, prompt:
                            Text("Share your feelings here")
                    .foregroundColor(.white.opacity(0.5))
                          , axis: .vertical)
                .foregroundColor(.white)
                .tint(.white)
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .lineLimit(1...5)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 22)
                )
                .overlay(RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                         
                )
                . padding(.horizontal, 36)
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Release")
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
                .padding(.bottom, 40)
            }
            .padding(.vertical, 20)
        }
    }
}


#Preview {
    WriteWishView(selectedLanternType: .lanternYellow)
}
