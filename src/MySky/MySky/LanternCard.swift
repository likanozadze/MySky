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
        VStack(spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 85)
                .shadow(color: .white.opacity(0.15), radius: 12)
            
            Text(title)
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.white)
                               
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .glassEffect(
            .clear,
            in: RoundedRectangle(cornerRadius: 28)
        )
  
    }
}

#Preview {
    LanternView()
}
