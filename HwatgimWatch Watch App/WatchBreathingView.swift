//
//  WatchBreathingView.swift
//  HwatgimWatch Watch App
//

import SwiftUI

struct WatchBreathingView: View {
    @State private var viewModel = WatchBreathingViewModel()

    private let maxCircleSize: CGFloat = 130
    private let circleStrokeWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                if viewModel.phase != .ready {
                    Text("사이클 \(viewModel.cycle)")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                breathingCircle
                    .frame(width: maxCircleSize, height: maxCircleSize)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if viewModel.phase != .ready {
                    Button {
                        viewModel.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }

    // MARK: - Breathing Circle

    private var breathingCircle: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(red: 0.6, green: 0.15, blue: 0.15)
                        .opacity(viewModel.glowOpacity),
                    lineWidth: circleStrokeWidth
                )
                .frame(
                    width: maxCircleSize * viewModel.circleScale,
                    height: maxCircleSize * viewModel.circleScale
                )

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

            VStack(spacing: 6) {
                Text(viewModel.phase.rawValue)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 15))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)

                if viewModel.phase != .ready && viewModel.phase != .paused {
                    Text(viewModel.phase.durationLabel)
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 10))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(viewModel.remainingSeconds)")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 26))
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
}

#Preview {
    WatchBreathingView()
}
