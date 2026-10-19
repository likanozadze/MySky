//
//  NewWriteWishView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

// ------------------------------------------------------------------------------------
// All the positions are measured from the CENTER of the screen:
// x = 0 / y = 0 is the center.
// x: negative values go left, positive values go right.
// y: negative values go up, positive values go down.
// ------------------------------------------------------------------------------------

import SwiftUI

enum WriteWishSettings {

    // Lantern
    static let lanternWidth: CGFloat = 200

    // Lantern while writing (keyboard closed)
    static let lanternWritingX: CGFloat = 0
    static let lanternWritingY: CGFloat = -120
    static let lanternWritingScale: CGFloat = 1.0

    // Lantern while typing (keyboard open), it moves up so the text field doesn't cover it
    static let lanternTypingX: CGFloat = 0
    static let lanternTypingY: CGFloat = -120
    static let lanternTypingScale: CGFloat = 1.0

    // Lantern after pressing Release
    static let lanternReleasedX: CGFloat = 0
    static let lanternReleasedY: CGFloat = -280
    static let lanternReleasedScale: CGFloat = 0.45

    // Wish text written on the lantern
    static let wishFontSize: CGFloat = 20
    static let wishMinimumScale: CGFloat = 0.8 // how much the text can shrink to fit (1 = never)
    static let wishMaxLines: Int = 7

    // Text field
    static let textFieldToButtonSpacing: CGFloat = 90 // space between the text field and the Release button (shrinks when the keyboard is open)

    // Matchbox (appears after pressing Release)
    static let matchboxWidth: CGFloat = 260
    static let matchboxX: CGFloat = 0
    static let matchboxY: CGFloat = 60
    // After taking the match, the matchbox moves to the left (only x, the label under it stays centered)
    static let matchboxMatchTakenX: CGFloat = -80

    // Match (appears when we tap the open matchbox, then follows the finger)
    static let matchWidth: CGFloat = 140
    // Which point of the match is under the finger, measured from the CENTER of the match image
    // (0, 0) = the finger holds the match from its middle
    // x: positive = the finger is more to the right of the match (towards the end of the stick)
    // y: positive = the finger is lower on the match
    static let matchHoldX: CGFloat = 22
    static let matchHoldY: CGFloat = -6

    // Animations
    static let releaseDuration: Double = 0.8 // lantern going up
    static let typingDuration: Double = 0.3  // lantern moving when the keyboard opens/closes
    static let matchboxDelay: Double = 0.4   // wait before the matchbox appears
    static let matchFollowSpeed: Double = 0.2 // how fast the match catches up with the finger (lower = faster)
}

struct NewWriteWishView: View {
    let selectedLanternType: LanternType

    @State private var wishText: String = ""
    @State private var isReleasing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isMatchboxOpened: Bool = false
    @State private var isMatchTaken: Bool = false
    // Where the finger/cursor is holding the match, nil = still at the matchbox
    @State private var matchLocation: CGPoint? = nil

    // Same ratio as the lantern image (79 x 116)
    private let lanternHeight: CGFloat = WriteWishSettings.lanternWidth * 116 / 79

    // Where the lantern is and how big, depending on what's happening
    private var lanternX: CGFloat {
        if isReleasing { return WriteWishSettings.lanternReleasedX }
        if isTextFieldFocused { return WriteWishSettings.lanternTypingX }
        return WriteWishSettings.lanternWritingX
    }

    private var lanternY: CGFloat {
        if isReleasing { return WriteWishSettings.lanternReleasedY }
        if isTextFieldFocused { return WriteWishSettings.lanternTypingY }
        return WriteWishSettings.lanternWritingY
    }

    private var lanternScale: CGFloat {
        if isReleasing { return WriteWishSettings.lanternReleasedScale }
        if isTextFieldFocused { return WriteWishSettings.lanternTypingScale }
        return WriteWishSettings.lanternWritingScale
    }

    // The hint under the matchbox, it changes at every step
    private var matchboxHint: String {
        if isMatchboxOpened == false { return "Tap to open the matchbox" }
        if isMatchTaken == false { return "Tap to take a match" }
        return "Set the match on fire"
    }

    // Where the center of the match image goes
    private func matchCenter(in size: CGSize) -> CGPoint {
        guard let matchLocation else {
            // Just taken: it starts from the matchbox
            return CGPoint(x: size.width / 2 + WriteWishSettings.matchboxX, y: size.height / 2 + WriteWishSettings.matchboxY)
        }
        return CGPoint(x: matchLocation.x - WriteWishSettings.matchHoldX, y: matchLocation.y - WriteWishSettings.matchHoldY)
    }

    var body: some View {
        ZStack {
            SkyBackground()

            // Lantern
            Lantern(type: selectedLanternType, isDimmed: true, width: WriteWishSettings.lanternWidth)
                .overlay(
                    // The wish written on the paper of the lantern
                    Text(wishText)
                        .font(.system(size: WriteWishSettings.wishFontSize, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.black.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineLimit(WriteWishSettings.wishMaxLines)
                        .minimumScaleFactor(WriteWishSettings.wishMinimumScale)
                        // Keep the text inside the body of the lantern, above the bottom rim
                        .frame(width: WriteWishSettings.lanternWidth * 0.75, height: lanternHeight * 0.6)
                        .offset(y: -lanternHeight * 0.05)
                )
                .scaleEffect(lanternScale)
                .offset(x: lanternX, y: lanternY)
                .animation(.easeInOut(duration: WriteWishSettings.typingDuration), value: isTextFieldFocused)
                // The keyboard should not push the lantern around, we move it ourselves
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard)

            // Text field and Release button, at the bottom (they go up with the keyboard)
            if isReleasing == false {
                VStack(spacing: 0) {
                    Spacer()

                    TextField("", text: $wishText, prompt:
                                Text("Share your feelings here")
                        .foregroundColor(.white.opacity(0.5))
                              , axis: .vertical)
                    .foregroundColor(.white)
                    .tint(.white)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .lineLimit(1...5)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .glassEffect(
                        .regular,
                        in: RoundedRectangle(cornerRadius: 22)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    . padding(.horizontal, 36)

                    Spacer()
                        .frame(minHeight: 24, maxHeight: WriteWishSettings.textFieldToButtonSpacing)

                    Button(action: {
                        isTextFieldFocused = false
                        withAnimation(.easeInOut(duration: WriteWishSettings.releaseDuration)) {
                            isReleasing = true
                        }
                    }) {
                        Text("Release")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .glassEffect(
                                .regular,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.bottom, 60)
                .transition(.opacity)
            }

            // After the release, the matchbox appears big at the center of the screen
            if isReleasing {
                VStack(spacing: 24) {
                    MatchboxView(isOpened: $isMatchboxOpened, width: WriteWishSettings.matchboxWidth) {
                        withAnimation(.spring(duration: 0.4)) {
                            isMatchTaken = true
                        }
                    }
                    .offset(x: isMatchTaken ? WriteWishSettings.matchboxMatchTakenX : WriteWishSettings.matchboxX)

                    Text(matchboxHint)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.4), value: matchboxHint)
                }
                .offset(y: WriteWishSettings.matchboxY)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard)
                .transition(
                    .scale(scale: 0.6)
                    .combined(with: .opacity)
                    .animation(.spring(duration: 0.6).delay(WriteWishSettings.matchboxDelay))
                )
            }

            // The match, it follows the finger (or the cursor on iPad/Mac) all over the screen
            if isMatchTaken {
                GeometryReader { proxy in
                    Image("match")
                        .resizable()
                        .scaledToFit()
                        .frame(width: WriteWishSettings.matchWidth)
                        .position(matchCenter(in: proxy.size))
                        .animation(.spring(response: WriteWishSettings.matchFollowSpeed, dampingFraction: 0.8), value: matchLocation)
                }
                // Makes the whole screen touchable, not only the match
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            matchLocation = drag.location
                        }
                )
                .onContinuousHover { phase in
                    if case .active(let location) = phase {
                        matchLocation = location
                    }
                }
                .ignoresSafeArea()
                .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
        .onTapGesture {
                    isTextFieldFocused = false
                }
    }

}


#Preview {
    NewWriteWishView(selectedLanternType: .lanternYellow)
}
