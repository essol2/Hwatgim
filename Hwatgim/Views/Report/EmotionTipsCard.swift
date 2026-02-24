//
//  EmotionTipsCard.swift
//  Hwatgim
//

import SwiftUI

struct EmotionTipsCard: View {
    let tips: [EmotionManagementTip]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.3))
                    .font(.system(size: 18))

                Text("감정 관리 팁")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)

                Spacer()

                if tips.first?.isPersonalized == true {
                    Text("맞춤")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 10))
                        .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.3))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.9, green: 0.75, blue: 0.3).opacity(0.15))
                        )
                }
            }

            // 팁 목록
            VStack(spacing: 12) {
                ForEach(tips) { tip in
                    tipRow(tip)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func tipRow(_ tip: EmotionManagementTip) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: tip.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 15))
                    .foregroundColor(.white)

                Text(tip.description)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(3)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}
