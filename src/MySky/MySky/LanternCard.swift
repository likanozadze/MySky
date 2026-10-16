//
//  LanternView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI

struct LanternCard: View {
    
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 85)
            
            Text(title)
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.white)
                               
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .cornerRadius(28)
    }
}

#Preview {
    LanternView()
}
