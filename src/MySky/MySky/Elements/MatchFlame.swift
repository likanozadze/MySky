//
//  MatchFlame.swift
//  MySky
//
//  Created by Mattia Silvestro on 19/10/2026.
//

// ------------------------------------------------------------------------------------
// A small flickering flame, drawn with shapes (no image needed).
// The bottom of the flame is the bottom of its frame, so we place it with its bottom on what is burning:
//
// MatchFlame()
//     .frame(width: 18, height: 34)
// ------------------------------------------------------------------------------------

import SwiftUI

struct MatchFlame: View {
    @State private var isFlickering = false

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: 40, height: 40)
                .blur(radius: 14)
                .offset(y: 8)

            // Outer flame
            FlameShape()
                .fill(LinearGradient(colors: [.red.opacity(0.8), .orange, .yellow], startPoint: .top, endPoint: .bottom))

            // Inner flame
            FlameShape()
                .fill(LinearGradient(colors: [.yellow, .white], startPoint: .top, endPoint: .bottom))
                .scaleEffect(x: 0.5, y: 0.55, anchor: .bottom)
        }
        .scaleEffect(x: isFlickering ? 0.92 : 1.05, y: isFlickering ? 1.08 : 0.94, anchor: .bottom)
        .rotationEffect(.degrees(isFlickering ? 3 : -3), anchor: .bottom)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true)) {
                isFlickering = true
            }
        }
    }
}

// Drop shape: pointy on top, round at the bottom
private struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tip = CGPoint(x: rect.midX, y: rect.minY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)
        path.move(to: tip)
        path.addCurve(to: bottom,
                      control1: CGPoint(x: rect.midX + rect.width * 0.2, y: rect.minY + rect.height * 0.35),
                      control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.maxY))
        path.addCurve(to: tip,
                      control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.maxY),
                      control2: CGPoint(x: rect.midX - rect.width * 0.2, y: rect.minY + rect.height * 0.35))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.black
        MatchFlame()
            .frame(width: 18, height: 34)
    }
}
