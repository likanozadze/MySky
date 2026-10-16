//
//  ContentView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to your quiet space")
            Image("Group")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
