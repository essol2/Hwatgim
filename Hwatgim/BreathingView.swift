//
//  BreathingView.swift
//  Hwatgim
//

import SwiftUI

// MARK: - Breathing Phase
enum BreathingPhase: String {
    case inhale = "들이마시세요"
    case hold = "잠시 멈추세요"
    case exhale = "내뱉으세요"
    case ready = "길게 눌러서 시작"
    case paused = "다시 눌러서 계속"

    var duration: Double {
        switch self {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        case .ready, .paused: return 0
        }
    }

    var durationLabel: String {
        switch self {
        case .inhale: return "4초간 들이마시기"
        case .hold: return "7초간 멈추기"
        case .exhale: return "8초간 내뱉기"
        case .ready, .paused: return ""
        }
    }

    /// Circle scale: inhale expands, hold stays big, exhale shrinks
    var targetScale: CGFloat {
        switch self {
        case .inhale, .hold: return 1.0
        case .exhale: return 0.6
        case .ready, .paused: return 0.6
        }
    }
}

// MARK: - BreathingViewModel
@Observable
final class BreathingViewModel {
    var phase: BreathingPhase = .ready
    var cycle: Int = 1
    var isPressing: Bool = false
    var circleScale: CGFloat = 0.6
    var glowOpacity: Double = 0.3
    var remainingSeconds: Int = 0

    private var phaseTimer: Timer?
    private var elapsed: Double = 0
    private var displayLink: CADisplayLink?
    private var animationStart: Date?
    private var animationFrom: CGFloat = 0.6
    private var animationTo: CGFloat = 0.6
    private var animationDuration: Double = 0

    // Haptic generators — 각 단계별로 다른 패턴의 햅틱
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    func startPressing() {
        isPressing = true
        impactHeavy.impactOccurred()

        if phase == .ready {
            // First start
            cycle = 1
            startPhase(.inhale)
        } else if phase == .paused {
            // Resume from where we left off
            resumeCurrentPhase()
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
        elapsed = 0
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.6
            glowOpacity = 0.3
        }
    }

    // MARK: - Phase Management

    private func startPhase(_ newPhase: BreathingPhase) {
        guard isPressing else {
            phase = .paused
            return
        }

        phase = newPhase
        elapsed = 0
        remainingSeconds = Int(newPhase.duration)
        triggerPhaseHaptic(newPhase)

        let duration = newPhase.duration

        // Animate circle
        animateCircle(to: newPhase.targetScale, duration: duration)

        // Animate glow
        let targetGlow: Double = (newPhase == .inhale || newPhase == .hold) ? 0.7 : 0.2
        withAnimation(.easeInOut(duration: duration)) {
            glowOpacity = targetGlow
        }

        // Schedule next phase
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
        case .inhale:
            startPhase(.hold)
        case .hold:
            startPhase(.exhale)
        case .exhale:
            cycle += 1
            startPhase(.inhale)
        default:
            break
        }
    }

    private func pauseBreathing() {
        // Capture current elapsed time
        if let start = animationStart {
            elapsed = Date().timeIntervalSince(start)
        }
        stopTimers()

        if phase != .ready {
            phase = .paused
        }
    }

    private func resumeCurrentPhase() {
        // We need to determine which phase was active before pausing
        // Since we store elapsed, we restart from paused state
        // For simplicity, restart from inhale of current cycle
        startPhase(.inhale)
    }

    private func stopTimers() {
        phaseTimer?.invalidate()
        phaseTimer = nil
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Circle Animation (manual for pausability)

    private func animateCircle(to target: CGFloat, duration: Double) {
        displayLink?.invalidate()

        animationFrom = circleScale
        animationTo = target
        animationDuration = duration
        animationStart = Date()

        let link = CADisplayLink(target: DisplayLinkProxy(update: { [weak self] in
            self?.updateCircleAnimation()
        }), selector: #selector(DisplayLinkProxy.handleUpdate))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func updateCircleAnimation() {
        guard let start = animationStart else { return }
        let elapsedTime = Date().timeIntervalSince(start)
        let progress = elapsedTime / animationDuration
        let clampedProgress = min(max(progress, 0), 1)

        // Update remaining seconds countdown
        let remaining = max(0, Int(ceil(animationDuration - elapsedTime)))
        if remaining != remainingSeconds {
            remainingSeconds = remaining
        }

        // Ease in-out curve
        let easedProgress = easeInOut(clampedProgress)
        circleScale = animationFrom + (animationTo - animationFrom) * easedProgress

        if clampedProgress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    private func easeInOut(_ t: Double) -> CGFloat {
        return CGFloat(t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
    }

    // MARK: - Haptics

    private func triggerPhaseHaptic(_ phase: BreathingPhase) {
        switch phase {
        case .inhale:
            // "쿵" — 묵직한 단일 진동으로 들이마시기 시작 알림
            impactHeavy.impactOccurred(intensity: 1.0)
        case .hold:
            // "따닥" — success 패턴(2번 진동)으로 멈추기 전환 알림
            notificationFeedback.notificationOccurred(.success)
        case .exhale:
            // "톡-톡" — soft 진동 2번 연속으로 내뱉기 전환 알림
            impactSoft.impactOccurred(intensity: 0.7)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.impactSoft.impactOccurred(intensity: 0.7)
            }
        default:
            break
        }
    }
}

// MARK: - DisplayLink Proxy (for @objc compatibility)
private class DisplayLinkProxy {
    let update: () -> Void
    init(update: @escaping () -> Void) {
        self.update = update
    }
    @objc func handleUpdate() {
        update()
    }
}

// MARK: - BreathingView
struct BreathingView: View {
    @State private var viewModel = BreathingViewModel()
    @State private var showRecordView = false
    @State private var currentQuote: Quote? = QuoteService.randomQuote()

    private let maxCircleSize: CGFloat = 300
    private let circleStrokeWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            VStack {
                // Quote
                quoteCard
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                // Breathing Circle
                breathingCircle
                    .frame(width: maxCircleSize, height: maxCircleSize)

                Spacer()

                // Quick Record Button
                quickRecordButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
        .fullScreenCover(isPresented: $showRecordView) {
            RecordView()
        }
        .onAppear {
            currentQuote = QuoteService.randomQuote()
        }
    }

    // MARK: - Quote Card
    private var quoteCard: some View {
        HStack(spacing: 0) {
            // 왼쪽 악센트 바
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.8),
                            Color(red: 0.7, green: 0.15, blue: 0.1).opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .padding(.vertical, 4)

            // 명언 텍스트
            VStack(spacing: 6) {
                if let quote = currentQuote {
                    Text(quote.text)
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("- \(quote.author)")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)

            // 불덩이 캐릭터
            Image("fire_angry")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuote = QuoteService.randomQuote()
            }
        }
    }

    // MARK: - Breathing Circle
    private var breathingCircle: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    Color(red: 0.6, green: 0.15, blue: 0.15).opacity(viewModel.glowOpacity),
                    lineWidth: circleStrokeWidth
                )
                .frame(
                    width: maxCircleSize * viewModel.circleScale,
                    height: maxCircleSize * viewModel.circleScale
                )

            // Inner gradient fill
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.45, green: 0.12, blue: 0.12).opacity(0.8),
                            Color(red: 0.25, green: 0.08, blue: 0.08).opacity(0.6),
                            Color(red: 0.12, green: 0.05, blue: 0.05).opacity(0.4),
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: maxCircleSize * viewModel.circleScale / 2
                    )
                )
                .frame(
                    width: (maxCircleSize - circleStrokeWidth * 2) * viewModel.circleScale,
                    height: (maxCircleSize - circleStrokeWidth * 2) * viewModel.circleScale
                )

            // Text content
            VStack(spacing: 12) {
                Text(viewModel.phase.rawValue)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 24))
                    .foregroundColor(.white)

                if viewModel.phase != .ready && viewModel.phase != .paused {
                    Text(viewModel.phase.durationLabel)
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(viewModel.remainingSeconds)")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 40))
                        .foregroundColor(.white.opacity(0.9))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: viewModel.remainingSeconds)
                }
            }
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !viewModel.isPressing {
                        viewModel.startPressing()
                    }
                }
                .onEnded { _ in
                    viewModel.stopPressing()
                }
        )
    }

    // MARK: - Quick Record Button
    private var quickRecordButton: some View {
        Button(action: {
            showRecordView = true
        }) {
            Text("분노 기록하기")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.12))
                )
        }
    }
}

#Preview {
    BreathingView()
}
