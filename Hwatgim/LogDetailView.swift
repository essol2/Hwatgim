//
//  LogDetailView.swift
//  Hwatgim
//

import SwiftUI
import SwiftData

struct LogDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: Item

    @State private var quote: Quote? = QuoteService.randomQuote()
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("돌아가기")
                                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // MARK: - Title
                        Text("기록 상세")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 26))
                            .foregroundColor(.white)

                        // MARK: - Date Section
                        dateSection

                        // MARK: - Intensity Section
                        intensitySection

                        // MARK: - Tags Section
                        tagsSection

                        // MARK: - Detail Section
                        if !item.detail.isEmpty {
                            detailSection
                        }

                        // MARK: - Quote Card
                        quoteCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .offset(x: dragOffset)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 25)
                .onChanged { value in
                    let horizontal = value.translation.width
                    let vertical = abs(value.translation.height)

                    if !isDragging && horizontal > 0 && horizontal > vertical {
                        isDragging = true
                    }

                    if isDragging {
                        dragOffset = max(0, horizontal)
                    }
                }
                .onEnded { value in
                    if isDragging {
                        if dragOffset > 120 || value.predictedEndTranslation.width > 500 {
                            dismiss()
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = 0
                            }
                        }
                    }
                    isDragging = false
                }
        )
        .navigationBarHidden(true)
    }

    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Text("날짜")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }

            Text(formattedDate)
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                .foregroundColor(.white)
        }
    }

    // MARK: - Intensity Section
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "flame")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Text("화 강도")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(index < item.intensity
                            ? Color(red: 0.9, green: 0.35, blue: 0.25)
                            : Color.white.opacity(0.15))
                }
            }
        }
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("태그")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.5))

            HStack(spacing: 8) {
                if !item.reason.isEmpty {
                    LogChip(title: item.reason, style: .reason)
                }
                if !item.mood.isEmpty {
                    LogChip(title: item.mood, style: .mood)
                }
            }
        }
    }

    // MARK: - Detail Section
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("상세 내용")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.5))

            Text(item.detail)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                )
        }
    }

    // MARK: - Quote Card
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                Text("이 순간을 기록했습니다")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 16))
                    .foregroundColor(.white)
            }

            Text("감정을 인지하고 기록하는 것만으로도 큰 발걸음입니다. 지금 이 순간의 당신을 응원합니다.")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.6))
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.35, green: 0.12, blue: 0.12))
        )
    }

    // MARK: - Helpers
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter.string(from: item.timestamp)
    }
}

#Preview {
    LogDetailView(
        item: Item(timestamp: Date(), reason: "업무", mood: "답답함", detail: "프로젝트 마감이 다가오는데 팀원들이 제대로 협조하지 않아서 너무 답답했다. 혼자서 모든 걸 떠안은 기분이었고, 커뮤니케이션도 제대로 안 돼서 스트레스가 심했다.", intensity: 4)
    )
}
