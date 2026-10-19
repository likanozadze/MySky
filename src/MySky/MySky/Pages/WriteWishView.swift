//
//  WriteWishView.swift
//  MySky
//
//  Created by Lika Nozadze on 16/10/2026.
//

import SwiftUI
import SwiftData

struct WriteWishView: View {
    let selectedLanternType: LanternType
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var wishText = ""
    @State private var isReleasing = false
    @State private var isMatchboxOpened = false
    @State private var isDimmed = true
    @State private var isFlying = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            SkyBackground()

            VStack(spacing: 24) {
                Spacer()

                Lantern(type: selectedLanternType, isDimmed: isDimmed, width: 200)
                    .overlay(wishLabel)
                    .padding(.bottom, 40)
                    .scaleEffect(isReleasing ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.8), value: isReleasing)
                    .offset(y: isFlying ? -900 : 0)
                    .animation(.easeIn(duration: 2.5), value: isFlying)

                Spacer()

                if isReleasing {
                    MatchboxView(isOpened: $isMatchboxOpened, onTapWhenOpened: releaseLantern)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    wishField
                    Spacer()
                    lightItUpButton
                }
            }
            .padding(.vertical, 20)
        }
        .onTapGesture { isTextFieldFocused = false }
        .toolbar(.hidden, for: .tabBar)
    }


    private var wishLabel: some View {
        Text(wishText)
            .font(.system(size: 17, design: .serif))
            .italic()
            .foregroundStyle(.black.opacity(0.75))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 40)
            .padding(.top, 20)
    }

    private var wishField: some View {
        TextField("", text: $wishText,
                  prompt: Text("Share your feelings here").foregroundStyle(.white.opacity(0.5)),
                  axis: .vertical)
            .foregroundStyle(.white)
            .tint(.white)
            .multilineTextAlignment(.center)
            .font(.system(size: 16))
            .lineLimit(1...5)
            .focused($isTextFieldFocused)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .glassOutlined(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 36)
    }

    private var lightItUpButton: some View {
        Button {
            isTextFieldFocused = false
            withAnimation(.easeInOut(duration: 0.6)) { isReleasing = true }
        } label: {
            Text("light it up")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .glassOutlined(Capsule())
        }
        .padding(.bottom, 40)
    }


    private func releaseLantern() {
        guard isDimmed else { return }
        isDimmed = false
        modelContext.insert(ReleasedLantern(type: selectedLanternType, wish: wishText))

        Task {
            try? await Task.sleep(for: .seconds(1))
            isFlying = true
            try? await Task.sleep(for: .seconds(2.8))   
            dismiss()
        }
    }
}


private extension View {
    func glassOutlined<S: Shape>(_ shape: S) -> some View {
        self
            .glassEffect(.regular, in: shape)
            .overlay(shape.stroke(.white.opacity(0.2), lineWidth: 1))
    }
}

#Preview {
    WriteWishView(selectedLanternType: .lanternYellow)
        .modelContainer(for: ReleasedLantern.self, inMemory: true)
}
