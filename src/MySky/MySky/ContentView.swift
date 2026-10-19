//
//  ContentView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnBoarding: Bool = false
    
    var body: some View {
        if hasSeenOnBoarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            LanternView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
         MyLanternsView()
                .tabItem { Label("Lanterns", systemImage: "lightbulb.fill") }
            Text("Profile").tabItem { Label("Profile", systemImage: "person")}
            
            
        }
        .tint(.white)
    }
    }

#Preview {
    ContentView()
}
