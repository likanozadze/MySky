//
//  FloatingModifier.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

// ------------------------------------------------------------------------------------
// We can use .goFloating on any view
// Image(...)
// .goFloating()
//
// OR if you want to specify different floating settings for different images you can do:
// Image(...)
// .goFloating(
//  floatX: 4,
//  floatY: 15,
//  tilt: 3,
//  speedX: 0.6,
//  speedY: 0.8,
//  tiltSpeed: 0.5
// )
//
// TODO: we can have a phase just like the Sky so multiple views do not animate in sync and look all the same
// ------------------------------------------------------------------------------------

import SwiftUI

// Default floating settings (the ones that apply in the .goFloating() call version with no parameters)
enum FloatingSettings {

    // How far it moves (points / degrees)
    static let floatX: Double = 6
    static let floatY: Double = 10
    static let tilt: Double = 2

    // How fast it moves
    static let speedX: Double = 1.7
    static let speedY: Double = 1.5
    static let tiltSpeed: Double = 1.4
}

// Extend View to support calling .goFloating()
extension View {
    // Every value is optional, if we don't pass any, the ones from FloatingSettings are used.
    func goFloating(
        floatX: Double = FloatingSettings.floatX,
        floatY: Double = FloatingSettings.floatY,
        tilt: Double = FloatingSettings.tilt,
        speedX: Double = FloatingSettings.speedX,
        speedY: Double = FloatingSettings.speedY,
        tiltSpeed: Double = FloatingSettings.tiltSpeed
    ) -> some View {
        modifier(FloatingModifier(
            floatX: floatX,
            floatY: floatY,
            tilt: tilt,
            speedX: speedX,
            speedY: speedY,
            tiltSpeed: tiltSpeed
        ))
    }
}

struct FloatingModifier: ViewModifier {
    // How far it moves (points / degrees)
    let floatX: Double
    let floatY: Double
    let tilt: Double

    // How fast it moves
    let speedX: Double
    let speedY: Double
    let tiltSpeed: Double

    // If the user has reduceMotion ON, the view will not move
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // this is what wraps the view we're applying .goFloating to inside an animated TimelineView
    func body(content: Content) -> some View {
        // TimelineView redraws every frame, so the movement is smooth
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let motion: Double = reduceMotion ? 0 : 1

            content
                // Offset to move it
                .offset(
                    x: sin(time * speedX) * floatX * motion,
                    y: cos(time * speedY) * floatY * motion
                )
                // Rotation effect to tilt it
                .rotationEffect(.degrees(sin(time * tiltSpeed) * tilt * motion))
        }
    }
}
