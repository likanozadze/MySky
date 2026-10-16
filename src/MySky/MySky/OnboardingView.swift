//
//  OnboardingView.swift
//  MySky
//
//  Created by Mattia Silvestro on 16/10/2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0

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
            Image("AppBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // TabView is the container for the pages, calls OnboardingPage for each page
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPage(
                        title: pages[index].title,
                        text: pages[index].body,
                        onGetStarted: getStartedAction(for: index)
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

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

    // Ret
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

    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
                .padding(.top, 50)

            Spacer()

            // Center image (we can parametrize this as well, so differetn pages can have a different image)
            Image("YellowLanternBig")
                .resizable()
                .scaledToFit()
                .frame(width: 130)
                .shadow(color: .orange.opacity(0.35), radius: 30)

            Spacer()
            
            // Bottom text
            Text(text)
                .font(.system(size: 15, weight: .semibold))
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
                            .foregroundColor(.white)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .cornerRadius(20)
                    }
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
