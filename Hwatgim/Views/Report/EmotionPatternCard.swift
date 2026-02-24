//
//  EmotionPatternCard.swift
//  Hwatgim
//

import SwiftUI
import Charts

struct EmotionPatternCard: View {
    let analysis: EmotionPatternAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - 요약 헤더
            summaryHeader

            // MARK: - 요일별 분노 빈도
            dayOfWeekSection

            // MARK: - 시간대별 분포
            timeOfDaySection

            // MARK: - TOP 원인
            if !analysis.topReasons.isEmpty {
                topReasonsSection
            }

            // MARK: - TOP 감정
            if !analysis.topMoods.isEmpty {
                topMoodsSection
            }

            // MARK: - 강도 추이
            if analysis.intensityTrend.count >= 2 {
                intensityTrendSection
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - 요약 헤더

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                    .font(.system(size: 18))
                Text("감정 패턴")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)
            }

            // 요약 수치
            HStack(spacing: 20) {
                statBadge(
                    value: "\(analysis.totalRecords)",
                    label: "총 기록",
                    icon: "doc.fill"
                )
                statBadge(
                    value: String(format: "%.1f", analysis.averageIntensity),
                    label: "평균 강도",
                    icon: "flame.fill"
                )
                if let peakDay = analysis.peakDay {
                    statBadge(
                        value: "\(peakDay)요일",
                        label: "피크 요일",
                        icon: "calendar"
                    )
                }
            }
        }
    }

    private func statBadge(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                Text(value)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 16))
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }

    // MARK: - 요일별 바 차트

    private var dayOfWeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("요일별 분노 빈도")

            Chart(analysis.dayOfWeekFrequencies) { day in
                BarMark(
                    x: .value("요일", day.dayName),
                    y: .value("건수", day.count)
                )
                .foregroundStyle(
                    day.count == (analysis.dayOfWeekFrequencies.map(\.count).max() ?? 0) && day.count > 0
                        ? Color(red: 0.9, green: 0.35, blue: 0.25)
                        : Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.4)
                )
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.05))
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.background(Color.clear)
            }
            .frame(height: 140)
        }
    }

    // MARK: - 시간대별 분포

    private var timeOfDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("시간대별 분포")

            VStack(spacing: 8) {
                ForEach(analysis.timeOfDayPatterns) { pattern in
                    HStack(spacing: 12) {
                        Text(pattern.hourRange)
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 110, alignment: .leading)

                        GeometryReader { geometry in
                            let maxPct = analysis.timeOfDayPatterns.map(\.percentage).max() ?? 1
                            let barWidth = maxPct > 0
                                ? (pattern.percentage / maxPct) * geometry.size.width
                                : 0

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.6))
                                .frame(width: max(barWidth, 2), height: 20)
                        }
                        .frame(height: 20)

                        Text("\(pattern.count)건")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
    }

    // MARK: - TOP 원인

    private var topReasonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("분노 원인 TOP \(analysis.topReasons.count)")

            VStack(spacing: 8) {
                ForEach(Array(analysis.topReasons.enumerated()), id: \.element.id) { index, reason in
                    HStack(spacing: 12) {
                        // 순위 뱃지
                        Text("\(index + 1)")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 13))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(index == 0
                                        ? Color(red: 0.9, green: 0.35, blue: 0.25)
                                        : Color.white.opacity(0.15))
                            )

                        Text(reason.reason)
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(reason.count)건")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                            .foregroundColor(.white.opacity(0.5))

                        Text(String(format: "%.0f%%", reason.percentage))
                            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 13))
                            .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                            .frame(width: 40, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - TOP 감정

    private var topMoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("주요 감정 유형")

            HStack(spacing: 8) {
                ForEach(analysis.topMoods) { mood in
                    HStack(spacing: 6) {
                        Text(mood.mood)
                            .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 13))
                            .foregroundColor(.white)
                        Text("\(mood.count)")
                            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 12))
                            .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.35, green: 0.12, blue: 0.12).opacity(0.5))
                    )
                }
            }
        }
    }

    // MARK: - 강도 추이 라인 차트

    private var intensityTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("분노 강도 추이")

            Chart(analysis.intensityTrend) { point in
                LineMark(
                    x: .value("날짜", point.date),
                    y: .value("강도", point.averageIntensity)
                )
                .foregroundStyle(Color(red: 0.9, green: 0.35, blue: 0.25))
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("날짜", point.date),
                    y: .value("강도", point.averageIntensity)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.3),
                            Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                PointMark(
                    x: .value("날짜", point.date),
                    y: .value("강도", point.averageIntensity)
                )
                .foregroundStyle(Color(red: 0.9, green: 0.35, blue: 0.25))
                .symbolSize(20)
            }
            .chartYScale(domain: 0...5)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.05))
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.background(Color.clear)
            }
            .frame(height: 140)
        }
    }

    // MARK: - Helper

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 15))
            .foregroundColor(.white.opacity(0.7))
    }
}
