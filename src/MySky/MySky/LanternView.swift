//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI


struct LanternView: View {
    @State private var selectedLantern: String?
    
    private let lanterns: [(image: String, title: String)] = [
        ("RedLantern", "Health"),
        ("YellowLantern", "Success"),
        ("BlueLantern", "Clarity"),
        ("PinkLantern", "Love")
    ]
    var body: some View {
        
        ZStack {
            Image("AppBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("What would you like to express today")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 90)
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ],
                    spacing: 25
                ){
                    ForEach(lanterns, id: \.title) { lantern in
                        Button {
                            withAnimation(.spring(response: 0.40, dampingFraction: 0.9)) {
                                selectedLantern = lantern.title
                            }
                        } label: {
                            LanternCard(
                                imageName: lantern.image,
                                title: lantern.title
                            )
                            .scaleEffect(
                                selectedLantern == lantern.title ? 1.05 : 1.0
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 28)
                                    .strokeBorder(
                                        .white.opacity(
                                            selectedLantern == lantern.title ? 0.20 : 0
                                        ),
                                        lineWidth: 0.2
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 25)
                
                Spacer()
                Button(action: {
                }) {
                    Text("Tap a lantern to begin")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        
                        .cornerRadius(20)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                
            }
            
        }
    }
}

#Preview {
   LanternView()
}
