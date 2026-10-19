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
    @State private var isReleasing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isMatchboxOpened: Bool = false
    
    var body: some View {
        ZStack {
            SkyBackground()
                .ignoresSafeArea()
            VStack (spacing: 24) {
                Spacer()
                
                Lantern(type: selectedLanternType, isDimmed: true, width: 200)
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
                    .scaleEffect(isReleasing ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.8), value: isReleasing)
                
                Spacer()
                
                if isReleasing == false {
                    TextField("", text: $wishText, prompt:
                                Text("Share your feelings here")
                        .foregroundColor(.white.opacity(0.5))
                              , axis: .vertical)
                    .foregroundColor(.white)
                    .tint(.white)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .lineLimit(1...5)
                    .focused($isTextFieldFocused)
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
                }
                
                Spacer()
                
                if isReleasing == false {
                    Button(action: {
                        isTextFieldFocused = false
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isReleasing = true
                        }
                    }) {
                        Text("light it up")
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
                } else{
                    MatchboxView(isOpened: $isMatchboxOpened)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical, 20)
        }
        .onTapGesture {
                    isTextFieldFocused = false
                }
        .toolbar(.hidden, for: .tabBar)
    }

}


#Preview {
    WriteWishView(selectedLanternType: .lanternYellow)
}
