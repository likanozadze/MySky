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
        NavigationStack {
            ZStack {
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    Text("What would you like to express today?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                   
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 18
                    ){
                        ForEach(lanterns, id: \.title) { lantern in
                            
                            NavigationLink(destination: WriteWishView(selectedLanternImage: lantern.image)) {
                                LanternCard (imageName: lantern.image, title: lantern.title)
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
}

#Preview {
    LanternView()
}
