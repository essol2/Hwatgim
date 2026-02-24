//
//  ReportLoadingView.swift
//  Hwatgim
//

import SwiftUI

struct ReportLoadingView: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    let isAI: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 펄스 아이콘
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.9, green: 0.2, blue: 0.15).opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.6, green: 0.15, blue: 0.15).opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: isAI ? "brain" : "chart.bar.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                    .rotationEffect(.degrees(rotation))
            }

            VStack(spacing: 8) {
                Text(isAI ? "AI가 분석하고 있어요" : "데이터를 분석하고 있어요")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)

                Text("잠시만 기다려주세요...")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            if isAI {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
