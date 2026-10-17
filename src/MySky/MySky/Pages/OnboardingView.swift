//
//  OnboardingView.swift
//  MySky
//
//  Created by Mattia Silvestro on 16/10/2026.
//

import SwiftUI

// We can change these values to quickly test how the lantern looks
// (how it floats is in FloatingModifier.swift)
enum LanternSettings {

    // Size and glow
    static let width: CGFloat = 130
    static let glowColor: Color = .orange
    static let glowOpacity: Double = 1.0
    static let glowRadius: CGFloat = 60
}

// We can change these values to test how the page elements appear when we swipe
enum PageAnimationSettings {
    
    // Turn the whole appear animation on or off
    static let isEnabled = true

    // Text and button
    static let duration: Double = 0.6        // how long the fade takes (seconds)
    static let rise: CGFloat = 12            // how far they slide up

    // Lantern
    static let lanternDuration: Double = 0.9 // how long the lantern takes to appear (seconds)
    static let lanternRise: CGFloat = 40     // how far below it starts
    static let lanternScale: CGFloat = 0.85  // how small it starts (1 = full size)

    // When each element starts, so they appear one after the other
    static let lanternDelay: Double = 0.1
    static let bodyDelay: Double = 0.2
    static let buttonDelay: Double = 0.35
}

struct OnboardingView: View {
    @State private var currentPage: Int? = 0 // which page is showing (optional because scrollPosition needs it)
    
    @State private var scrollOffset: CGFloat = 0 // how far we've swiped, passed to the sky
    @State private var hasAppeared = false // becomes true when the screen shows, so the first page animates in too

    // If the user has reduceMotion ON, the pages don't animate in at all
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                            // When the animation is off (or reduceMotion is ON), every page is always "active", so everything is just visible and nothing animates
                            isActive: !PageAnimationSettings.isEnabled || reduceMotion || (hasAppeared && index == currentPage),
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
            .onAppear { hasAppeared = true }

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
    let isActive: Bool // true when this page is the one on screen, used to animate its elements in
    var onGetStarted: (() -> Void)? = nil // optional parameter, it's nil on everypage but the last one.

    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text(title)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
                .appearAnimation(isActive: isActive, delay: 0)
                .padding(.top, 50)

            Spacer()

            // Lantern with its glow, floating (see FloatingModifier.swift)
            Image("YellowLanternBig")
                .resizable()
                .scaledToFit()
                .frame(width: LanternSettings.width)
                .shadow(
                    color: LanternSettings.glowColor.opacity(LanternSettings.glowOpacity),
                    radius: LanternSettings.glowRadius
                )
                .goFloating()
                // Lantern fades in and rises from below
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1 : PageAnimationSettings.lanternScale)
                .offset(y: isActive ? 0 : PageAnimationSettings.lanternRise)
                .animation(
                    .easeOut(duration: PageAnimationSettings.lanternDuration)
                        .delay(isActive ? PageAnimationSettings.lanternDelay : 0),
                    value: isActive
                )

            Spacer()
            
            // Bottom text
            Text(text)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .appearAnimation(isActive: isActive, delay: PageAnimationSettings.bodyDelay)
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
                    .appearAnimation(isActive: isActive, delay: PageAnimationSettings.buttonDelay)
                }
            }
            .frame(height: 56)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 24)
    }
}

// Fade in and slide up when the page comes on screen, fade out when it leaves.
// Written once here so the title, text and button all animate the same way.
extension View {
    func appearAnimation(isActive: Bool, delay: Double) -> some View {
        self
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : PageAnimationSettings.rise)
            .animation(
                .easeOut(duration: PageAnimationSettings.duration)
                    .delay(isActive ? delay : 0), // only wait when appearing, leave all together
                value: isActive
            )
    }
}

#Preview {
    OnboardingView()
}
