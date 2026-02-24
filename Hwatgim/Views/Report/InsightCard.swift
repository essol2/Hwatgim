//
//  InsightCard.swift
//  Hwatgim
//

import SwiftUI

struct InsightCard: View {
    let insight: NaturalLanguageInsight
    let sentiment: SentimentResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack(spacing: 8) {
                Image(systemName: insight.isAIGenerated ? "brain" : "lightbulb.fill")
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                    .font(.system(size: 18))

                Text(insight.isAIGenerated ? "AI 인사이트" : "분석 인사이트")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)

                if insight.isAIGenerated {
                    Text("AI")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 10))
                        .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.3))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.9, green: 0.75, blue: 0.3).opacity(0.15))
                        )
                }

                Spacer()
            }

            // 요약 문단
            Text(insight.summary)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)

            // 주요 발견 목록
            if !insight.keyFindings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(insight.keyFindings.enumerated()), id: \.offset) { _, finding in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color(red: 0.9, green: 0.35, blue: 0.25))
                                .frame(width: 6, height: 6)
                                .padding(.top, 7)

                            Text(finding)
                                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.03))
                )
            }

            // 감성 분석 결과 (있을 경우)
            if let sentiment = sentiment {
                sentimentBadge(sentiment)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func sentimentBadge(_ sentiment: SentimentResult) -> some View {
        HStack(spacing: 10) {
            Image(systemName: sentimentIcon(for: sentiment.overallScore))
                .font(.system(size: 16))
                .foregroundColor(sentimentColor(for: sentiment.overallScore))

            VStack(alignment: .leading, spacing: 2) {
                Text("글 감성 분석")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                    .foregroundColor(.white.opacity(0.4))
                Text(sentiment.dominantEmotion)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // 스코어 바
            HStack(spacing: 4) {
                Text(String(format: "%.1f", sentiment.overallScore))
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func sentimentIcon(for score: Double) -> String {
        switch score {
        case ..<(-0.3): return "cloud.rain.fill"
        case -0.3..<0.0: return "cloud.fill"
        case 0.0..<0.3: return "cloud.sun.fill"
        default: return "sun.max.fill"
        }
    }

    private func sentimentColor(for score: Double) -> Color {
        switch score {
        case ..<(-0.3): return Color(red: 0.4, green: 0.5, blue: 0.9)
        case -0.3..<0.0: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case 0.0..<0.3: return Color(red: 0.9, green: 0.8, blue: 0.4)
        default: return Color(red: 0.9, green: 0.7, blue: 0.2)
        }
    }
}
