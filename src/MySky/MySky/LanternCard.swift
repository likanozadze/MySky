//
//  LanternCard.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct LanternCard: View {
    
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
            Text(title)
        }
        
    }
}

//#Preview {
   // LanternCard(imageName: <#String#>, title: <#String#>)
//}
