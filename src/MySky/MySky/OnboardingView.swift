//
//  OnboardingView.swift
//  MySky
//
//  Created by Mattia Silvestro on 16/10/2026.
//

import SwiftUI

// We can change these values to quickly test how the lantern looks and moves
enum LanternSettings {
    
    // Size and glow
    static let width: CGFloat = 130
    static let glowColor: Color = .orange
    static let glowOpacity: Double = 1.0
    static let glowRadius: CGFloat = 60

    // How far it moves
    static let floatX: Double = 6
    static let floatY: Double = 10
    static let tilt: Double = 2

    // How fast it moves
    static let speedX: Double = 1.7
    static let speedY: Double = 1.5
    static let tiltSpeed: Double = 1.4
}

struct OnboardingView: View {
    @State private var currentPage: Int? = 0 // which page is showing (optional because scrollPosition needs it)
    
    @State private var scrollOffset: CGFloat = 0 // how far we've swiped, passed to the sky

    // All the pages of our onboarding
    // if you want to add a page, you can just create a new array element here
    private let pages: [(title: String, body: String)] = [
        ("Welcome to your quiet space",
         "A place to pause, process, and release what you've been holding onto."),
        
        ("Relearn the art of letting go",
         "For centuries, sky lanterns have been used to carry heavy burdens and quiet wishes into the night. We've brought this ancient release ritual to you"),
        
        ("A tactile release, in three steps",
         "Write what you feel, strike a match to ignite your intention and watch it gently float away."),
        
    ]

    var body: some View {
        ZStack {
            SkyBackground(scrollOffset: scrollOffset)

            // Horizontal paging ScrollView holds the pages, creating one OnboardingPage per page.
            // We use it instead of a TabView because it tells us exactly how far we've swiped.
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPage(
                            title: pages[index].title,
                            text: pages[index].body,
                            onGetStarted: getStartedAction(for: index)
                        )
                        .containerRelativeFrame([.horizontal, .vertical]) // each page is one screen
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging) // snaps to one page at a time
            .scrollIndicators(.hidden)
            .scrollPosition(id: $currentPage)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.x
            } action: { _, newOffset in
                scrollOffset = newOffset
            }

            // This draws the circles at the bottom of the screen that count the pages
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(.white.opacity(index == currentPage ? 1 : 0.35))
                            .frame(width: 6, height: 6)
                    }
                }
                .animation(.easeInOut, value: currentPage)
                .padding(.bottom, 30)
            }
        }
    }

    // Returns the getStarted function only if the current index page is the last page
    private func getStartedAction(for index: Int) -> (() -> Void)? {
        guard index == pages.count - 1 else { return nil }
        return { getStarted() }
    }

    private func getStarted() {
        // TODO: change view and make sure onboarding doesnt happen again
    }
}

// this lets us write the page code once and reutilize it for every page
struct OnboardingPage: View {
    
    // "parameters"
    let title: String
    let text: String
    var onGetStarted: (() -> Void)? = nil // optional parameter, it's nil on everypage but the last one.

    // If the user has reduceMotion ON, the lantern will not move
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text(title)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
                .padding(.top, 50)

            Spacer()

            // TimelineView to draw and animate the lantern.
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSinceReferenceDate
                let motion: Double = reduceMotion ? 0 : 1

                Image("YellowLanternBig")
                    .resizable()
                    .scaledToFit()
                    .frame(width: LanternSettings.width)
                    .shadow(
                        color: LanternSettings.glowColor.opacity(LanternSettings.glowOpacity),
                        radius: LanternSettings.glowRadius
                    )
                    // Offset to move it
                    .offset(
                        x: sin(time * LanternSettings.speedX) * LanternSettings.floatX * motion,
                        y: cos(time * LanternSettings.speedY) * LanternSettings.floatY * motion
                    )
                    // Rotation effect to tilt it
                    .rotationEffect(.degrees(sin(time * LanternSettings.tiltSpeed) * LanternSettings.tilt * motion))
            }

            Spacer()
            
            // Bottom text
            Text(text)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .frame(height: 100, alignment: .top)

            // Fixed-height ZStack keeps the layout identical on every page
            ZStack {
                if let onGetStarted { // only show the button on the last page
                    Button(action: onGetStarted) {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent) // native Liquid Glass button
                    .controlSize(.large)
                    .buttonBorderShape(.capsule)
                    .tint(.orange) // warm glass to match the lantern glow
                    .padding(.horizontal, 16)
                    
                }
            }
            .frame(height: 56)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView()
}
