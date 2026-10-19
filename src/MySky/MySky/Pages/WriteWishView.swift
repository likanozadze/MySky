//
//  NewWriteWishView.swift
//  MySky
//
//  Created by Mattia Silvestro on 19/10/2026.
//

// ------------------------------------------------------------------------------------
// The wish ritual, step by step:
// 1. Write the wish on the lantern and press Release
// 2. Open the matchbox and take a match (it follows the finger)
// 3. Swipe the match fast on the red side of the matchbox: it's on fire, the lantern comes down
// 4. Touch the burner of the lantern with the flame: the lantern is on fire, the match falls
// 5. Swipe up: the lantern flies away in the sky
//
// All the positions are measured from the CENTER of the screen:
// x = 0 / y = 0 is the center.
// x: negative values go left, positive values go right.
// y: negative values go up, positive values go down.
// ------------------------------------------------------------------------------------

import SwiftUI
import SwiftData

// Where the lantern is and how big, at each step
struct LanternPlacement {
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
}

enum WriteWishSettings {

    // MARK: Lantern

    static let lanternWidth: CGFloat = 200

    static let lanternWriting = LanternPlacement(x: 0, y: -120, scale: 1.0)   // while writing (keyboard closed)
    static let lanternTyping = LanternPlacement(x: 0, y: -230, scale: 0.6)    // while typing (keyboard open), it can move up so the text field doesn't cover it
    static let lanternReleased = LanternPlacement(x: 0, y: -280, scale: 0.45) // after pressing Release
    static let lanternLighting = LanternPlacement(x: 0, y: -120, scale: 1.0)  // after the match is on fire, it comes down again so we can light it
    static let lanternFlown = LanternPlacement(x: 0, y: -300, scale: 0.2)     // after the swipe up, it flies up in the sky and becomes small

    // Hints "Set the lantern on fire" and "Swipe up to let it go", same place as the matchbox hint
    static let lanternHintY: CGFloat = 200

    // MARK: 1. Writing

    // Wish text written on the lantern
    static let wishFontSize: CGFloat = 20
    static let wishMinimumScale: CGFloat = 0.8 // how much the text can shrink to fit (1 = never)
    static let wishMaxLines: Int = 7

    static let textFieldToButtonSpacing: CGFloat = 90 // space between the text field and the Release button (shrinks when the keyboard is open)

    static let typingDuration: Double = 0.3  // lantern moving when the keyboard opens/closes
    static let releaseDuration: Double = 0.8 // lantern going up after pressing Release

    // MARK: 2. Matchbox and match

    // Matchbox (appears after pressing Release)
    static let matchboxWidth: CGFloat = 260
    static let matchboxX: CGFloat = 0
    static let matchboxY: CGFloat = 60
    // After taking the match, the matchbox moves to the left (only x, the label under it stays centered)
    static let matchboxMatchTakenX: CGFloat = -80
    static let matchboxDelay: Double = 0.4 // wait before the matchbox appears

    // Match (appears when we tap the open matchbox, then follows the finger)
    static let matchWidth: CGFloat = 140
    // Which point of the match is under the finger, measured from the CENTER of the match image
    // (0, 0) = the finger holds the match from its middle
    // x: positive = the finger is more to the right of the match (towards the end of the stick)
    // y: positive = the finger is lower on the match
    static let matchHoldX: CGFloat = 22
    static let matchHoldY: CGFloat = -6
    // Where the head of the match is, measured in the match image (166 x 142, 0, 0 = top left corner)
    static let matchHeadInImage = CGPoint(x: 22, y: 80)
    static let matchFollowSpeed: Double = 0.2 // how fast the match catches up with the finger (lower = faster)

    // MARK: 3. Striking the match

    // The two ends of the red strip, measured in the closed matchbox image (303 x 304, 0, 0 = top left corner)
    static let strikerStart = CGPoint(x: 198, y: 231) // bottom end
    static let strikerEnd = CGPoint(x: 268, y: 76)    // top end
    static let strikeDistance: CGFloat = 22 // how close the head of the match must pass to the red strip
    static let strikeSpeed: CGFloat = 1500  // how fast the swipe must be (points per second), higher = harder
    static let strikeSpeedWindow: Double = 0.1 // the speed is the average of the last 0.1 seconds, so tiny jumps don't count

    // Flame on the head of the match
    static let flameWidth: CGFloat = 18
    static let flameHeight: CGFloat = 34

    // After the match is on fire, the matchbox slides to the left until it's out of the screen
    static let matchboxGoneX: CGFloat = -800
    static let matchboxLeaveDuration: Double = 2.0 // matchbox sliding out of the screen
    static let matchboxLeaveDelay: Double = 0.3    // wait before the matchbox starts moving, so we see the flame first
    static let lanternComeDownDuration: Double = 2.0 // lantern coming down

    // MARK: 4. Lighting the lantern

    // The center of the burner (the dimmed part at the bottom of the lantern), measured in the lantern image (79 x 116, 0, 0 = top left corner)
    static let lanternBurnerInImage = CGPoint(x: 42, y: 103)
    static let lanternFireDistance: CGFloat = 25 // how close the flame must get to the center of the burner

    static let lanternStartFloatingDuration: Double = 1.5 // lantern going from still to floating after it's on fire

    // Match falling after the lantern is on fire
    static let matchFallDuration: Double = 1.0
    static let matchFallRotation: Double = -50 // degrees, it turns a bit while falling

    // MARK: 5. Letting it go

    // To let it go the swipe must be BOTH long enough and fast enough, a slow drag only lifts it a bit
    static let swipeUpDistance: CGFloat = 120 // how far up the finger must go
    static let swipeUpSpeed: CGFloat = 900    // how fast the finger must be going up when it's lifted (points per second)
    static let swipeUpFollow: CGFloat = 0.13  // while dragging, the lantern follows the finger a bit (0 = not at all, 1 = exactly)

    static let lanternFlyDuration: Double = 10.0 // lantern flying up in the sky after the swipe up

    // MARK: Debug (set them to false before shipping)

    // Shows the swipe area on the matchbox (red), the head of the match (blue dot) and the speed of the swipe
    static let showStrikeDebug: Bool = false
    // Shows the burner area (red, green when the flame is on it) and the point of the flame that lights it (orange dot)
    static let showLanternFireDebug: Bool = false
}

// The steps of the ritual, in order. We only go forward
private enum WishStep: Int, Comparable {
    case writing        // writing the wish
    case released       // pressed Release, the matchbox appears
    case matchboxOpened // tapped the matchbox
    case matchTaken     // took a match, it follows the finger
    case matchLit       // struck the match, the lantern comes down
    case lanternReady   // the lantern finished coming down, we can light it
    case lanternLit     // the lantern is on fire, the match falls
    case flying         // swiped up, the lantern flies away

    static func < (lhs: WishStep, rhs: WishStep) -> Bool { lhs.rawValue < rhs.rawValue }
}

// Sizes of the images, the positions in the settings are measured on them
private enum ImageSize {
    static let lantern = CGSize(width: 79, height: 116)
    static let match = CGSize(width: 166, height: 142)
    static let matchboxWidth: CGFloat = 303
}

struct WriteWishView: View {
    let selectedLanternType: LanternType
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var step: WishStep = .writing
    @State private var wishText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    // Match
    // Where the finger/cursor is holding the match, nil = still at the matchbox
    @State private var matchLocation: CGPoint? = nil
    // Last positions of the head of the match and when it was there, to measure the speed of the swipe
    @State private var recentMatchHeads: [(point: CGPoint, time: Date)] = []

    // Lantern
    // How much the lantern is lifted while the finger is dragging up (before letting it go)
    @State private var lanternDragOffset: CGFloat = 0

    // Where things are on the screen, to know where the red strip and the burner are
    @State private var matchboxFrame: CGRect = .zero
    // The lantern is drawn at the center of this area, then moved and scaled
    @State private var lanternAreaFrame: CGRect = .zero
    // Where the area of the match starts (it ignores the safe area, so it can be different from the others)
    @State private var matchAreaOrigin: CGPoint = .zero

    // Only for the debug
    @State private var debugSpeed: CGFloat = 0           // last speed of the match measured
    @State private var debugIsOnStriker: Bool = false    // if the head of the match was on the red strip
    @State private var debugIsOnBurner: Bool = false     // if the flame was on the burner

    // Same ratio as the lantern image
    private let lanternHeight: CGFloat = WriteWishSettings.lanternWidth * ImageSize.lantern.height / ImageSize.lantern.width

    // How much the match image is scaled on the screen
    private let matchScale: CGFloat = WriteWishSettings.matchWidth / ImageSize.match.width

    // MARK: - Steps

    private var isReleasing: Bool { step >= .released }
    private var isMatchTaken: Bool { step >= .matchTaken }
    private var isMatchLit: Bool { step >= .matchLit }
    private var isLanternReady: Bool { step >= .lanternReady }
    private var isLanternLit: Bool { step >= .lanternLit }
    private var isLanternFlying: Bool { step >= .flying }

    // The matchbox opens itself (with its own animation), it just tells us
    private var isMatchboxOpened: Binding<Bool> {
        Binding(
            get: { step >= .matchboxOpened },
            set: { isOpened in
                if isOpened && step < .matchboxOpened {
                    step = .matchboxOpened
                }
            }
        )
    }

    private var lanternPlacement: LanternPlacement {
        if isLanternFlying { return WriteWishSettings.lanternFlown }
        if isMatchLit { return WriteWishSettings.lanternLighting }
        if isReleasing { return WriteWishSettings.lanternReleased }
        if isTextFieldFocused { return WriteWishSettings.lanternTyping }
        return WriteWishSettings.lanternWriting
    }

    // The hint under the matchbox, it changes at every step
    private var matchboxHint: String {
        switch step {
        case .writing, .released: "Tap to open the matchbox"
        case .matchboxOpened: "Tap to take a match"
        default: "Swipe the match fast on the red side"
        }
    }

    // MARK: - Body
    var body: some View {
        Color.clear
            .overlay {
                if isReleasing == false {
                    writingControls
                }
            }
            .background {
                ZStack {
                    SkyBackground()

                    lanternLayer

                    lanternFireHint

                    if isReleasing {
                        matchboxLayer
                    }

                    letGoHint

                    closingLine

                    if isLanternLit && isLanternFlying == false {
                        swipeUpLayer
                    }

                    if isMatchTaken {
                        matchLayer
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .sensoryFeedback(.impact(weight: .medium), trigger: isMatchLit)
            .sensoryFeedback(.success, trigger: isLanternLit)
            .sensoryFeedback(.impact(weight: .light), trigger: isLanternFlying)
    }

    // MARK: - Lantern

    private var lanternLayer: some View {
        Lantern(type: selectedLanternType, isDimmed: isLanternLit == false, width: WriteWishSettings.lanternWidth)
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
            // Once it's on fire it starts floating (slowly, from still)
            .goFloating(intensity: isLanternLit ? 1 : 0)
            .animation(.easeInOut(duration: WriteWishSettings.lanternStartFloatingDuration), value: isLanternLit)
            .scaleEffect(lanternPlacement.scale)
            .offset(x: lanternPlacement.x, y: lanternPlacement.y + lanternDragOffset)
            .animation(.easeInOut(duration: WriteWishSettings.typingDuration), value: isTextFieldFocused)
            // The keyboard should not push the lantern around, we move it ourselves
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { frame in
                lanternAreaFrame = frame
            }
    }

    // MARK: - 1. Writing

    // Text field and Release button, at the bottom (they go up with the keyboard)
    private var writingControls: some View {
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
            .padding(.horizontal, 36)

            Spacer()
                .frame(minHeight: 24, maxHeight: WriteWishSettings.textFieldToButtonSpacing)

            Button(action: release) {
                Text("Light it up")
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
        .background(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { isTextFieldFocused = false }
                )
                .transition(.opacity)
    }

    private func release() {
        isTextFieldFocused = false
        withAnimation(.easeInOut(duration: WriteWishSettings.releaseDuration)) {
            step = .released
        }
    }

    // MARK: - 2. Matchbox

    // After the release, the matchbox appears big at the center of the screen
    private var matchboxLayer: some View {
        VStack(spacing: 24) {
            MatchboxView(isOpened: isMatchboxOpened, width: WriteWishSettings.matchboxWidth) {
                // Tapping again does nothing, we only go forward
                guard step < .matchTaken else { return }
                withAnimation(.spring(duration: 0.4)) {
                    step = .matchTaken
                }
            }
            // Measured before the offset, so the frame includes it
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { frame in
                matchboxFrame = frame
            }
            .offset(x: isMatchTaken ? WriteWishSettings.matchboxMatchTakenX : WriteWishSettings.matchboxX)

            Text(matchboxHint)
                .hintStyle()
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: matchboxHint)
        }
        .offset(y: WriteWishSettings.matchboxY)
        // When the match is on fire, the matchbox slides out of the screen on the left.
        // It stays in the view (just out of the screen), a removal transition would make it disappear at once
        .offset(x: isMatchLit ? WriteWishSettings.matchboxGoneX : 0)
        .animation(
            .easeInOut(duration: WriteWishSettings.matchboxLeaveDuration).delay(WriteWishSettings.matchboxLeaveDelay),
            value: isMatchLit
        )
        .allowsHitTesting(isMatchLit == false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .transition(
            .scale(scale: 0.6)
            .combined(with: .opacity)
            .animation(.spring(duration: 0.6).delay(WriteWishSettings.matchboxDelay))
        )
    }

    // MARK: - Match

    // The match, it follows the finger (or the cursor on iPad/Mac) all over the screen
    private var matchLayer: some View {
        GeometryReader { proxy in
            if WriteWishSettings.showStrikeDebug {
                // Fades out with its own quick animation as soon as the match is on fire
                // (otherwise it would follow the slow animation of the lantern coming down)
                strikeDebugView
                    .opacity(isMatchLit ? 0 : 1)
                    .animation(.easeOut(duration: 0.3), value: isMatchLit)
            }
            if WriteWishSettings.showLanternFireDebug && isMatchLit && isLanternLit == false {
                lanternFireDebugView
            }

            matchImage
                .position(matchCenter(in: proxy.size))
                .animation(.spring(response: WriteWishSettings.matchFollowSpeed, dampingFraction: 0.8), value: matchLocation)
        }
        // Makes the whole screen touchable, not only the match
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    // After the lantern is on fire we don't hold the match anymore
                    guard isLanternLit == false else { return }
                    // drag.time is when the finger was really there, not when we got the update
                    moveMatch(to: drag.location, time: drag.time)
                }
                .onEnded { _ in
                    // A new touch can start anywhere, it's not a swipe
                    recentMatchHeads.removeAll()
                }
        )
        .onContinuousHover { phase in
            if case .active(let location) = phase, isLanternLit == false {
                moveMatch(to: location)
            } else {
                recentMatchHeads.removeAll()
            }
        }
        .ignoresSafeArea()
        .onGeometryChange(for: CGPoint.self) { proxy in
            proxy.frame(in: .global).origin
        } action: { origin in
            matchAreaOrigin = origin
        }
        // Once the match is gone, the screen is free for the next step
        .allowsHitTesting(isLanternLit == false)
        .transition(.scale(scale: 0.5).combined(with: .opacity))
    }

    private var matchImage: some View {
        Image("match")
            .resizable()
            .scaledToFit()
            .frame(width: WriteWishSettings.matchWidth)
            .overlay {
                // The bottom of the flame sits on the head of the match.
                // It's always there (just hidden), so when it lights up it doesn't fly in from somewhere else
                MatchFlame()
                    .frame(width: WriteWishSettings.flameWidth, height: WriteWishSettings.flameHeight)
                    .scaleEffect(isMatchLit ? 1 : 0.1, anchor: .bottom)
                    .opacity(isMatchLit ? 1 : 0)
                    .animation(.easeOut(duration: 0.25), value: isMatchLit)
                    .position(x: matchHeadOnImage.x, y: flameMiddleY(headY: matchHeadOnImage.y))
            }
            .overlay {
                // DEBUG: the point of the match that has to pass over the strip
                if WriteWishSettings.showStrikeDebug {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .position(matchHeadOnImage)
                        .opacity(isMatchLit ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: isMatchLit)
                }
            }
            .overlay {
                // DEBUG: the point of the flame that has to touch the burner
                if WriteWishSettings.showLanternFireDebug && isMatchLit && isLanternLit == false {
                    Circle()
                        .fill(Color.orange)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .frame(width: 8, height: 8)
                        .position(x: matchHeadOnImage.x, y: flameMiddleY(headY: matchHeadOnImage.y))
                }
            }
            .rotationEffect(.degrees(isLanternLit ? WriteWishSettings.matchFallRotation : 0))
    }

    // Every time the finger/cursor moves while holding the match
    private func moveMatch(to location: CGPoint, time: Date = Date()) {
        matchLocation = location
        strikeMatchIfNeeded(fingerAt: location, time: time)
        lightLanternIfNeeded(fingerAt: location)
    }

    // Where the center of the match image goes
    private func matchCenter(in size: CGSize) -> CGPoint {
        if isLanternLit {
            // We let it go: it falls down out of the screen, from where it was
            let x = (matchLocation?.x ?? size.width / 2) - WriteWishSettings.matchHoldX
            return CGPoint(x: x, y: size.height + WriteWishSettings.matchWidth)
        }
        guard let matchLocation else {
            // Just taken: it starts from the matchbox
            return CGPoint(x: size.width / 2 + WriteWishSettings.matchboxX, y: size.height / 2 + WriteWishSettings.matchboxY)
        }
        return CGPoint(x: matchLocation.x - WriteWishSettings.matchHoldX, y: matchLocation.y - WriteWishSettings.matchHoldY)
    }

    // Where the head of the match is on the match image, as it's drawn on the screen
    private var matchHeadOnImage: CGPoint {
        CGPoint(x: WriteWishSettings.matchHeadInImage.x * matchScale,
                y: WriteWishSettings.matchHeadInImage.y * matchScale)
    }

    // Where the head of the match is when the finger is at this point
    private func matchHead(fingerAt location: CGPoint) -> CGPoint {
        let head = WriteWishSettings.matchHeadInImage
        return CGPoint(
            x: location.x - WriteWishSettings.matchHoldX + (head.x - ImageSize.match.width / 2) * matchScale,
            y: location.y - WriteWishSettings.matchHoldY + (head.y - ImageSize.match.height / 2) * matchScale
        )
    }

    // The bottom of the flame sits on the head, so its middle is a bit higher
    private func flameMiddleY(headY: CGFloat) -> CGFloat {
        headY - WriteWishSettings.flameHeight / 2 + 4
    }

    // MARK: - 3. Striking the match

    // The two ends of the red strip, in the same space as the match
    private var striker: (start: CGPoint, end: CGPoint) {
        let unit = matchboxFrame.width / ImageSize.matchboxWidth
        func onScreen(_ point: CGPoint) -> CGPoint {
            CGPoint(x: matchboxFrame.minX + point.x * unit - matchAreaOrigin.x,
                    y: matchboxFrame.minY + point.y * unit - matchAreaOrigin.y)
        }
        return (onScreen(WriteWishSettings.strikerStart), onScreen(WriteWishSettings.strikerEnd))
    }

    // Called every time the match moves: if the head passed over the red strip fast enough, the match is on fire
    private func strikeMatchIfNeeded(fingerAt location: CGPoint, time: Date) {
        guard isMatchLit == false, matchboxFrame != .zero else { return }

        let head = matchHead(fingerAt: location)
        let previous = recentMatchHeads.last
        recentMatchHeads.append((head, time))
        // Keep only the positions of the last moment
        recentMatchHeads.removeAll { time.timeIntervalSince($0.time) > WriteWishSettings.strikeSpeedWindow }
        guard let previous, let oldest = recentMatchHeads.first else { return }

        // Average speed over the last moment: the touches often arrive in bursts, a few milliseconds apart,
        // so measuring between only two of them makes even a slow swipe look super fast
        let seconds = time.timeIntervalSince(oldest.time)
        guard seconds >= WriteWishSettings.strikeSpeedWindow / 2 else { return }
        let speed = hypot(head.x - oldest.point.x, head.y - oldest.point.y) / seconds

        // We check the whole path from the previous position, so a very fast swipe can't jump over the strip
        let distance = segmentDistance(previous.point, head, striker.start, striker.end)

        if WriteWishSettings.showStrikeDebug {
            debugSpeed = speed
            debugIsOnStriker = distance <= WriteWishSettings.strikeDistance
        }

        if speed >= WriteWishSettings.strikeSpeed && distance <= WriteWishSettings.strikeDistance {
            withAnimation(.easeInOut(duration: WriteWishSettings.lanternComeDownDuration)) {
                step = .matchLit
            } completion: {
                // Only once the lantern is down, so the burner is really where we check it
                if step == .matchLit {
                    step = .lanternReady
                }
            }
        }
    }

    // MARK: - 4. Lighting the lantern

    // Hint while the lantern comes down, until it's on fire.
    // Always there (just hidden), like the matchbox, so it fades nicely
    private var lanternFireHint: some View {
        Text("Set the lantern on fire")
            .hintStyle()
            .offset(y: WriteWishSettings.lanternHintY)
            .opacity(isMatchLit && isLanternLit == false ? 1 : 0)
            .animation(.easeInOut(duration: 0.4).delay(isLanternLit ? 0 : WriteWishSettings.matchboxLeaveDelay + 0.4), value: isMatchLit)
            .animation(.easeInOut(duration: 0.4), value: isLanternLit)
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
    }

    // The center of the burner of the lantern, in the same space as the match.
    // It uses where the lantern ends up, not where it is during the animation
    private var lanternBurner: CGPoint {
        let unit = WriteWishSettings.lanternWidth / ImageSize.lantern.width * lanternPlacement.scale
        let burner = WriteWishSettings.lanternBurnerInImage
        return CGPoint(
            x: lanternAreaFrame.midX + lanternPlacement.x + (burner.x - ImageSize.lantern.width / 2) * unit - matchAreaOrigin.x,
            y: lanternAreaFrame.midY + lanternPlacement.y + (burner.y - ImageSize.lantern.height / 2) * unit - matchAreaOrigin.y
        )
    }

    // Called every time the match moves: if the flame touches the burner, the lantern is on fire and we let the match go
    private func lightLanternIfNeeded(fingerAt location: CGPoint) {
        guard isMatchLit, isLanternReady, isLanternLit == false, lanternAreaFrame != .zero else { return }

        let head = matchHead(fingerAt: location)
        let flame = CGPoint(x: head.x, y: flameMiddleY(headY: head.y))
        let isOnBurner = hypot(flame.x - lanternBurner.x, flame.y - lanternBurner.y) <= WriteWishSettings.lanternFireDistance

        if WriteWishSettings.showLanternFireDebug {
            debugIsOnBurner = isOnBurner
        }

        if isOnBurner {
            // Like gravity: slow at the start, faster and faster
            withAnimation(.timingCurve(0.55, 0, 1, 0.45, duration: WriteWishSettings.matchFallDuration)) {
                step = .lanternLit
            }
        }
    }

    // MARK: - 5. Letting it go

    // Hint after the lantern is on fire (waits for the match to fall), until we let it go
    private var letGoHint: some View {
        Text("Swipe up to let it go")
            .hintStyle()
            .offset(y: WriteWishSettings.lanternHintY)
            .opacity(isLanternLit && isLanternFlying == false ? 1 : 0)
            .animation(.easeInOut(duration: 0.4).delay(WriteWishSettings.matchFallDuration), value: isLanternLit)
            .animation(.easeInOut(duration: 0.4), value: isLanternFlying)
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
    }
    
    private var closingLine: some View {
        Text("Your wish is on its way")
            .hintStyle()
            .offset(y: WriteWishSettings.lanternHintY)
            .opacity(isLanternFlying ? 1 : 0)
            .animation(
                .easeInOut(duration: 1.0).delay(isLanternFlying ? 1.0 : 0),
                value: isLanternFlying
            )
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
    }
    // Swipe up anywhere on the screen to let the lantern go
    private var swipeUpLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        // Only up, and just a bit, so it feels like we're lifting it
                        lanternDragOffset = min(0, drag.translation.height) * WriteWishSettings.swipeUpFollow
                    }
                    .onEnded(letGoIfNeeded)
            )
    }

    private func letGoIfNeeded(_ drag: DragGesture.Value) {
        let isFarEnough = drag.translation.height <= -WriteWishSettings.swipeUpDistance
        let isFastEnough = drag.velocity.height <= -WriteWishSettings.swipeUpSpeed
       
        if isFarEnough && isFastEnough {
            guard step < .flying else { return }
            modelContext.insert(ReleasedLantern(type: selectedLanternType, wish: wishText))

            withAnimation(.easeInOut(duration: WriteWishSettings.lanternFlyDuration)) {
                step = .flying
                lanternDragOffset = 0
            }
            Task {
                try? await Task.sleep(for: .seconds(WriteWishSettings.lanternFlyDuration))
                dismiss()
            }
        } else {
            withAnimation(.spring(duration: 0.4)) {
                lanternDragOffset = 0
            }
        }
    }
}

// MARK: - Debug

extension WriteWishView {
    // The swipe area is every point closer than strikeDistance to the line between the two ends of the strip,
    // so we draw that line very thick with round ends. It turns green while the head is on it.
    var strikeDebugView: some View {
        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: striker.start)
                path.addLine(to: striker.end)
            }
            .stroke(
                (debugIsOnStriker ? Color.green : Color.red).opacity(0.35),
                style: StrokeStyle(lineWidth: WriteWishSettings.strikeDistance * 2, lineCap: .round)
            )

            // The two ends of the strip
            ForEach([striker.start, striker.end], id: \.x) { point in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .position(point)
            }

            // Speed of the swipe, green when it's fast enough
            debugLabel("speed \(Int(debugSpeed)) / \(Int(WriteWishSettings.strikeSpeed))",
                       isGreen: debugSpeed >= WriteWishSettings.strikeSpeed)
        }
        .allowsHitTesting(false)
    }

    // The burner area is every point closer than lanternFireDistance to the center of the burner.
    // It turns green while the flame (orange dot) is on it. It's only checked after the lantern finished coming down
    var lanternFireDebugView: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill((debugIsOnBurner ? Color.green : Color.red).opacity(0.35))
                .frame(width: WriteWishSettings.lanternFireDistance * 2, height: WriteWishSettings.lanternFireDistance * 2)
                .position(lanternBurner)

            // Center of the burner
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .position(lanternBurner)

            debugLabel(isLanternReady ? "lantern ready" : "lantern coming down...", isGreen: isLanternReady)
        }
        .allowsHitTesting(false)
    }

    private func debugLabel(_ text: String, isGreen: Bool) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(isGreen ? .green : .white)
            .padding(8)
            .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            .padding(.top, 70)
            .padding(.leading, 16)
    }
}

// The style of the hints that tell what to do at each step
private extension Text {
    func hintStyle() -> Text {
        self
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
    }
}

#Preview {
    WriteWishView(selectedLanternType: .lanternYellow)
}
