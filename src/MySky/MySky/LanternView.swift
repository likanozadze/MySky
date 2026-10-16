//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct LanternView: View {
    
    
    private let lanterns: [(image: String, title: String)] = [
        ("RedLantern", "Health"),
        ("YellowLantern", "Success"),
        ("BlueLantern", "Clarity"),
        ("PinkLantern", "Love")
    ]
    var body: some View {
        
        VStack {
            Text("What would you like to express today")
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 60
            ){
                ForEach(lanterns, id: \.title) { lantern in
                    LanternCard(
                        imageName: lantern.image,
                        title: lantern.title)
                }
                
            }
            
        }
        
        Spacer()
        Button("Tap a lantern to begin") {
        }
        
    }
    
}
#Preview {
   LanternView()
}
