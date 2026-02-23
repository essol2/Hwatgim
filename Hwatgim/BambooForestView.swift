//
//  BambooForestView.swift
//  Hwatgim
//

import SwiftUI

// MARK: - Flying Character Model
private struct FlyingCharacter: Identifiable {
    let id = UUID()
    let character: String
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
    let delay: Double
    let duration: Double
}

// MARK: - BambooForestView
struct BambooForestView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var isFlying = false
    @State private var flyingCharacters: [FlyingCharacter] = []
    @State private var showText = true
    @State private var textOpacity: Double = 1.0
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("마음속 이야기를 꺼내보세요")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                            .foregroundColor(.white)

                        Text("아무도 보지 않아요. 쓰고 나면 사라져요.")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Text input area
                    GeometryReader { geometry in
                        ZStack(alignment: .topLeading) {
                            // Background
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.06))

                            if showText {
                                // Placeholder
                                if text.isEmpty && !isTextFocused {
                                    Text("여기에 마음껏 적어보세요...")
                                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 16))
                                        .foregroundColor(.white.opacity(0.25))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 16)
                                }

                                // Text editor
                                TextEditor(text: $text)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .focused($isTextFocused)
                                    .opacity(textOpacity)
                                    .disabled(isFlying)
                            }

                            // Flying characters overlay
                            ForEach(flyingCharacters) { char in
                                FlyingCharacterView(character: char, isFlying: isFlying)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // Fly away button
                    Button(action: startFlyingAnimation) {
                        HStack(spacing: 8) {
                            Image(systemName: "wind")
                                .font(.system(size: 16))
                            Text("날려보내기")
                                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 17))
                        }
                        .foregroundColor(.white.opacity(canFly ? 1.0 : 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canFly
                                      ? Color(red: 0.75, green: 0.2, blue: 0.2)
                                      : Color.white.opacity(0.1))
                        )
                    }
                    .disabled(!canFly)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }

    private var canFly: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isFlying
    }

    // MARK: - Flying Animation

    private func startFlyingAnimation() {
        isTextFocused = false
        isFlying = true

        // Generate flying characters from the text
        generateFlyingCharacters()

        // Fade out the text editor
        withAnimation(.easeOut(duration: 0.3)) {
            textOpacity = 0
        }

        // After a brief moment, hide text editor and start flying
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showText = false

            // Trigger the fly animation
            withAnimation(.easeOut(duration: 0.1)) {
                // Characters are now visible at their start positions
            }

            // After all characters have flown away, dismiss
            let maxDuration = flyingCharacters.map { $0.delay + $0.duration }.max() ?? 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration + 0.3) {
                dismiss()
            }
        }
    }

    private func generateFlyingCharacters() {
        let chars = Array(text)
        guard !chars.isEmpty else { return }

        // Layout characters roughly matching TextEditor positions
        var characters: [FlyingCharacter] = []
        let lineHeight: CGFloat = 24
        let charWidth: CGFloat = 14
        let maxCharsPerLine = 18
        let startXOffset: CGFloat = 30
        let startYOffset: CGFloat = 20

        for (index, char) in chars.enumerated() {
            let line = index / maxCharsPerLine
            let col = index % maxCharsPerLine

            let startX = startXOffset + CGFloat(col) * charWidth
            let startY = startYOffset + CGFloat(line) * lineHeight

            // Random end position (fly outward)
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 300...600)
            let endX = startX + cos(angle) * distance
            let endY = startY - CGFloat.random(in: 200...500) // Mostly fly upward

            let rotation = Double.random(in: -360...360)
            let delay = Double(index) * 0.02 + Double.random(in: 0...0.3)
            let duration = Double.random(in: 0.8...1.5)

            characters.append(FlyingCharacter(
                character: String(char),
                startX: startX,
                startY: startY,
                endX: endX,
                endY: endY,
                rotation: rotation,
                delay: delay,
                duration: duration
            ))
        }

        flyingCharacters = characters
    }

}

// MARK: - Flying Character View
private struct FlyingCharacterView: View {
    let character: FlyingCharacter
    let isFlying: Bool

    @State private var hasStarted = false

    var body: some View {
        Text(character.character)
            .font(.system(size: 16))
            .foregroundColor(.white)
            .position(
                x: hasStarted ? character.endX : character.startX,
                y: hasStarted ? character.endY : character.startY
            )
            .rotationEffect(.degrees(hasStarted ? character.rotation : 0))
            .opacity(hasStarted ? 0 : 1)
            .onAppear {
                guard isFlying else { return }
                withAnimation(
                    .easeOut(duration: character.duration)
                    .delay(character.delay)
                ) {
                    hasStarted = true
                }
            }
    }
}

#Preview {
    BambooForestView()
}
