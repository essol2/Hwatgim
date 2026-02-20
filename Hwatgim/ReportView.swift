//
//  ReportView.swift
//  Hwatgim
//

import SwiftUI

struct ReportView: View {
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // AI 아이콘 + 글로우
                ZStack {
                    // 배경 글로우
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.9, green: 0.2, blue: 0.15).opacity(0.12),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale)

                    // 아이콘 원
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.6, green: 0.15, blue: 0.15).opacity(0.3), lineWidth: 1)
                        )

                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                }

                // 타이틀
                VStack(spacing: 10) {
                    Text("AI 분노 보고서")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 24))
                        .foregroundColor(.white)

                    Text("준비중이에요")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }

                // 설명 카드
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(icon: "chart.bar.fill", text: "나의 분노 패턴을 분석해요")
                    featureRow(icon: "lightbulb.fill", text: "맞춤형 감정 관리 팁을 드려요")
                    featureRow(icon: "calendar.badge.clock", text: "주간/월간 감정 리포트를 만들어요")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                )
                .padding(.horizontal, 32)

                Spacer()

                // 하단 안내
                Text("곧 만나요!")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.15
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                .frame(width: 24)

            Text(text)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    ReportView()
}
