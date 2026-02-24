//
//  ReportUpsellBanner.swift
//  Hwatgim
//
//  iOS <26 사용자에게 AI 기능 안내 / 추후 페이월 배너
//

import SwiftUI

struct ReportUpsellBanner: View {
    let tier: ReportAccessTier

    var body: some View {
        if tier == .basicAnalysis {
            basicAnalysisBanner
        }
        // .premiumAI → 배너 없음
        // .free → 추후 결제 유도 배너 추가
    }

    // iOS <26 안내 배너
    private var basicAnalysisBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.3))

            VStack(alignment: .leading, spacing: 4) {
                Text("통계 기반 분석 리포트")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 14))
                    .foregroundColor(.white)

                Text("iOS 26 이상에서 AI 맞춤 분석을 받아보세요")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.2, green: 0.15, blue: 0.05).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.9, green: 0.75, blue: 0.3).opacity(0.2), lineWidth: 1)
                )
        )
    }
}
