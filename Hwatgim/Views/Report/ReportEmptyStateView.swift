//
//  ReportEmptyStateView.swift
//  Hwatgim
//

import SwiftUI

struct ReportEmptyStateView: View {
    let currentCount: Int
    let minimumRequired: Int

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // 아이콘
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 80, height: 80)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }

            // 메시지
            VStack(spacing: 8) {
                Text("기록이 부족해요")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                    .foregroundColor(.white)

                Text("분석을 위해 최소 \(minimumRequired)개의 기록이 필요합니다")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))

                // 진행 바
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentCount), total: Double(minimumRequired))
                        .tint(Color(red: 0.9, green: 0.35, blue: 0.25))
                        .scaleEffect(y: 2)

                    Text("\(currentCount) / \(minimumRequired)건")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }

            Spacer()

            Text("홈에서 감정을 기록해보세요")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                .foregroundColor(.white.opacity(0.3))
                .padding(.bottom, 16)
        }
    }
}
