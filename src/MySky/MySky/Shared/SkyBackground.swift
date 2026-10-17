//
//  SkyBackground.swift
//  MySky
//
//  Created by Mattia Silvestro on 17/10/2026.
//

import SwiftUI

// Reusable SkyBackground. Instead of "Image("AppBackground")" we can use "SkyBackground(scrollOffset: 0)" on any page

// We can change these values to quickly test how the stars look and move
enum SkySettings {
    
    // How many stars and how big
    static let starCount = 80
    static let minStarSize: CGFloat = 1
    static let maxStarSize: CGFloat = 2.5

    // How bright they are
    static let minOpacity: Double = 0.15
    static let maxOpacity: Double = 0.9

    // How fast they move and twinkle
    static let driftSpeed: Double = 0.02
    static let twinkleSpeed: Double = 1.4

    // How much the stars follow a swipe (0 = not at all, 1 = as fast as the page)
    // This is used on the Onboarding because we can swipe the pages and it looks better if the stars swipe with it
    static let parallax: Double = 0.5
}

struct SkyBackground: View {
    // How far the screen in front has scrolled sideways (in points), so the stars can follow it.
    // We can set it at 0 on screens that don't scroll.
    var scrollOffset: CGFloat = 0

    // If the user has reduceMotion ON, the stars stay still
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Stars are created once, so they don't jump around when the view redraws
    @State private var stars: [Star] = (0..<SkySettings.starCount).map { _ in Star.random() }

    var body: some View {
        ZStack {
            
            // Static background underneath this animated one
            Image("AppBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // TimelineView redraws every frame, canvas draws all the stars in one go
            TimelineView(.animation) { context in
                let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                let parallax = reduceMotion ? 0 : SkySettings.parallax

                Canvas { canvas, size in
                    // How many screen widths we've scrolled
                    let scrolled = Double(scrollOffset / size.width)
                    
                    for star in stars {
                        // Drift to the right, and move with the swipe.
                        // Faster stars follow the swipe more, which gives a sense of depth.
                        let rawX = star.x
                            + time * SkySettings.driftSpeed * star.speed
                            - scrolled * parallax * star.speed
                        
                        // Wrap around, so a star leaving one edge comes back on the other
                        let x = rawX - rawX.rounded(.down)
                        
                        // Small up and down sway
                        let y = star.y + sin(time * 0.1 + star.phase) * 0.005

                        // Twinkle, brightness goes smoothly up and down
                        let twinkle = (sin(time * SkySettings.twinkleSpeed * star.speed + star.phase) + 1) / 2
                        
                        let opacity = SkySettings.minOpacity + (SkySettings.maxOpacity - SkySettings.minOpacity) * twinkle
                        
                        // The actual star is just a circle, we could use an image here instead
                        let rect = CGRect(
                            x: x * size.width - star.size / 2,
                            y: y * size.height - star.size / 2,
                            width: star.size,
                            height: star.size
                        )
                        canvas.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

// Struct for the star, where it starts, how big it is and its own speed, so they don't all move together.
private struct Star {
    let x: Double       // 0 = left edge, 1 = right edge
    let y: Double       // 0 = top, 1 = bottom
    let size: CGFloat
    let speed: Double
    let phase: Double   // offsets the twinkle so stars don't blink in sync

    // Randomizes the settings of a star
    static func random() -> Star {
        Star(
            x: .random(in: 0...1),
            y: .random(in: 0...1),
            size: .random(in: SkySettings.minStarSize...SkySettings.maxStarSize),
            speed: .random(in: 0.5...1.5),
            phase: .random(in: 0...(2 * .pi))
        )
    }
}

#Preview {
    SkyBackground()
}
