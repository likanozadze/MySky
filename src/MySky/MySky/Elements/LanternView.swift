//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI


struct LanternView: View {
    @State private var selectedLantern: String?
    
    private let lanterns: [(type: LanternType, title: String)] = [
        (.lanternRed, "Health"),
        (.lanternYellow, "Success"),
        (.lanternBlue, "Clarity"),
        (.lanternPink, "Love")
    ]
    var body: some View {
        // No NavigationStack here, it's in MainTabView (ContentView.swift)
        ZStack {
            SkyBackground()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("What do you want to\n wish for?")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)


             
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 18
                    ){
                        ForEach(lanterns, id: \.title) { lantern in

                            NavigationLink(destination: WriteWishView(selectedLanternType: lantern.type)) {
                                LanternCard (type: lantern.type, title: lantern.title)
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

#Preview {
    NavigationStack {
        LanternView()
    }
}
