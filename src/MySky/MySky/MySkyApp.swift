//
//  MySkyApp.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI
import SwiftData

@main
struct MySkyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: ReleasedLantern.self)
      
    }
}
