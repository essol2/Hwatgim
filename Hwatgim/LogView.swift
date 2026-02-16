//
//  LogView.swift
//  Hwatgim
//

import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.1)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Header
                        headerSection

                        // MARK: - Weekly Heatmap
                        weeklyHeatmapCard

                        // MARK: - Recent Records
                        recentRecordsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea())
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("마음 로그")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 28))
                .foregroundColor(.white)

            Text("당신의 감정 기록을 확인하세요")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Weekly Heatmap Card
    private var weeklyHeatmapCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                    .font(.system(size: 18))

                Text("이번 주 화 온도")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)
            }

            // Weekday labels + circles
            let weekData = weeklyData()
            HStack(spacing: 0) {
                ForEach(weekData, id: \.label) { day in
                    VStack(spacing: 10) {
                        Text(day.label)
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                            .foregroundColor(.white.opacity(0.6))

                        Circle()
                            .fill(heatColor(for: day.count))
                            .frame(width: 36, height: 36)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Recent Records Section
    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16))

                Text("최근 기록")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)
            }

            if items.isEmpty {
                VStack(spacing: 12) {
                    Text("아직 기록이 없습니다")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Group items by date
                let grouped = groupedByDate()
                ForEach(grouped, id: \.date) { group in
                    recordCard(date: group.date, items: group.items)
                }
            }
        }
    }

    // MARK: - Record Card
    private func recordCard(date: String, items: [Item]) -> some View {
        VStack(spacing: 10) {
            ForEach(items) { item in
                NavigationLink(destination: LogDetailView(item: item)) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(date)
                                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 16))
                                .foregroundColor(.white)

                            Spacer()

                            // Flame indicators (max 5)
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(index < item.intensity
                                            ? Color(red: 0.9, green: 0.35, blue: 0.25)
                                            : Color.white.opacity(0.15))
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            if !item.reason.isEmpty {
                                LogChip(title: item.reason, style: .reason)
                            }
                            if !item.mood.isEmpty {
                                LogChip(title: item.mood, style: .mood)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private struct DayData {
        let label: String
        let count: Int
    }

    private func weeklyData() -> [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Sun ... 7=Sat. We want Mon=1st
        let mondayOffset = (weekday == 1) ? -6 : (2 - weekday)
        let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today)!

        let labels = ["월", "화", "수", "목", "금", "토", "일"]
        var result: [DayData] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: monday)!
            let count = items.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }.map(\.intensity).max() ?? 0
            result.append(DayData(label: labels[i], count: count))
        }
        return result
    }

    private func heatColor(for count: Int) -> Color {
        switch count {
        case 0:
            return Color.white.opacity(0.1)
        case 1:
            return Color(red: 0.55, green: 0.18, blue: 0.18)
        case 2:
            return Color(red: 0.7, green: 0.22, blue: 0.2)
        case 3:
            return Color(red: 0.82, green: 0.28, blue: 0.22)
        default:
            return Color(red: 0.92, green: 0.32, blue: 0.22)
        }
    }

    private struct DateGroup {
        let date: String
        let items: [Item]
    }

    private func groupedByDate() -> [DateGroup] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"

        var dict: [String: (date: Date, items: [Item])] = [:]

        for item in items {
            let key = formatter.string(from: item.timestamp)
            if dict[key] != nil {
                dict[key]!.items.append(item)
            } else {
                dict[key] = (date: item.timestamp, items: [item])
            }
        }

        return dict
            .sorted { $0.value.date > $1.value.date }
            .map { DateGroup(date: $0.key, items: $0.value.items) }
    }
}

// MARK: - Log Chip
struct LogChip: View {
    let title: String
    let style: ChipStyle

    enum ChipStyle {
        case reason, mood
    }

    var body: some View {
        Text(title)
            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
            .foregroundColor(style == .reason ? .white : .white.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(style == .reason
                        ? Color(red: 0.55, green: 0.15, blue: 0.15)
                        : Color.white.opacity(0.12))
            )
    }
}

#Preview {
    LogView()
        .modelContainer(for: Item.self, inMemory: true)
}
