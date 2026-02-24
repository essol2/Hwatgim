//
//  WatchBreathingViewModel.swift
//  HwatgimWatch Watch App
//

import SwiftUI
import WatchKit

@Observable
final class WatchBreathingViewModel {
    var phase: BreathingPhase = .ready
    var cycle: Int = 1
    var isPressing: Bool = false
    var circleScale: CGFloat = 0.6
    var glowOpacity: Double = 0.3
    var remainingSeconds: Int = 0

    private var phaseTimer: Timer?
    private var animationTimer: Timer?
    private var animationStart: Date?
    private var animationFrom: CGFloat = 0.6
    private var animationTo: CGFloat = 0.6
    private var animationDuration: Double = 0

    // MARK: - Public API

    func startPressing() {
        isPressing = true
        WKInterfaceDevice.current().play(.start)

        if phase == .ready {
            cycle = 1
            startPhase(.inhale)
        } else if phase == .paused {
            startPhase(.inhale)
        }
    }

    func stopPressing() {
        isPressing = false
        pauseBreathing()
    }

    func reset() {
        stopTimers()
        phase = .ready
        cycle = 1
        circleScale = 0.6
        glowOpacity = 0.3
    }

    // MARK: - Phase Management

    private func startPhase(_ newPhase: BreathingPhase) {
        guard isPressing else {
            phase = .paused
            return
        }

        phase = newPhase
        remainingSeconds = Int(newPhase.duration)
        triggerPhaseHaptic(newPhase)

        let duration = newPhase.duration

        animateCircle(to: newPhase.targetScale, duration: duration)

        let targetGlow: Double = (newPhase == .inhale || newPhase == .hold) ? 0.7 : 0.2
        withAnimation(.easeInOut(duration: duration)) {
            glowOpacity = targetGlow
        }

        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.advancePhase()
            }
        }
    }

    private func advancePhase() {
        guard isPressing else {
            phase = .paused
            return
        }

        switch phase {
        case .inhale: startPhase(.hold)
        case .hold:   startPhase(.exhale)
        case .exhale:
            cycle += 1
            startPhase(.inhale)
        default: break
        }
    }

    private func pauseBreathing() {
        stopTimers()
        if phase != .ready {
            phase = .paused
        }
    }

    private func stopTimers() {
        phaseTimer?.invalidate()
        phaseTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }

    // MARK: - Circle Animation (Timer-based, replaces CADisplayLink)

    private func animateCircle(to target: CGFloat, duration: Double) {
        animationTimer?.invalidate()

        animationFrom = circleScale
        animationTo = target
        animationDuration = duration
        animationStart = Date()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateCircleAnimation()
            }
        }
    }

    private func updateCircleAnimation() {
        guard let start = animationStart else { return }
        let elapsed = Date().timeIntervalSince(start)
        let progress = min(max(elapsed / animationDuration, 0), 1)

        let remaining = max(0, Int(ceil(animationDuration - elapsed)))
        if remaining != remainingSeconds {
            remainingSeconds = remaining
        }

        let eased = easeInOut(progress)
        circleScale = animationFrom + (animationTo - animationFrom) * eased

        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }

    private func easeInOut(_ t: Double) -> CGFloat {
        CGFloat(t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
    }

    // MARK: - Haptics (watchOS)

    private func triggerPhaseHaptic(_ phase: BreathingPhase) {
        switch phase {
        case .inhale:
            WKInterfaceDevice.current().play(.start)
        case .hold:
            WKInterfaceDevice.current().play(.success)
        case .exhale:
            WKInterfaceDevice.current().play(.click)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                WKInterfaceDevice.current().play(.click)
            }
        default:
            break
        }
    }
}
