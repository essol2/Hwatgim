//
//  EmotionAnalyzer.swift
//  Hwatgim
//

import Foundation

struct EmotionAnalyzer {

    // MARK: - 요일별 분노 빈도
    static func dayOfWeekFrequencies(from items: [Item]) -> [DayOfWeekFrequency] {
        let calendar = Calendar.current
        let dayNames = ["월", "화", "수", "목", "금", "토", "일"]

        var buckets: [Int: [Item]] = [:]
        for i in 0..<7 { buckets[i] = [] }

        for item in items {
            let weekday = calendar.component(.weekday, from: item.timestamp)
            // Sun=1..Sat=7 → Mon=0..Sun=6
            let index = (weekday + 5) % 7
            buckets[index, default: []].append(item)
        }

        return (0..<7).map { i in
            let dayItems = buckets[i] ?? []
            let avg = dayItems.isEmpty ? 0.0 :
                Double(dayItems.map(\.intensity).reduce(0, +)) / Double(dayItems.count)
            return DayOfWeekFrequency(
                dayName: dayNames[i],
                dayIndex: i,
                count: dayItems.count,
                averageIntensity: avg
            )
        }
    }

    // MARK: - 시간대별 패턴
    static func timeOfDayPatterns(from items: [Item]) -> [TimeOfDayPattern] {
        let calendar = Calendar.current
        let slots: [(String, ClosedRange<Int>)] = [
            ("새벽 (0-6시)", 0...5),
            ("아침 (6-12시)", 6...11),
            ("오후 (12-18시)", 12...17),
            ("밤 (18-24시)", 18...23)
        ]
        let total = max(items.count, 1)

        return slots.map { (name, range) in
            let count = items.filter { item in
                let hour = calendar.component(.hour, from: item.timestamp)
                return range.contains(hour)
            }.count
            return TimeOfDayPattern(
                hourRange: name,
                count: count,
                percentage: Double(count) / Double(total) * 100
            )
        }
    }

    // MARK: - 분노 원인 TOP N
    static func topReasons(from items: [Item], limit: Int = 3) -> [ReasonFrequency] {
        let total = max(items.count, 1)
        var counts: [String: Int] = [:]

        for item in items {
            let reason = item.reason == "기타" ? item.customReason : item.reason
            guard !reason.isEmpty else { continue }
            counts[reason, default: 0] += 1
        }

        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ReasonFrequency(
                reason: $0.key,
                count: $0.value,
                percentage: Double($0.value) / Double(total) * 100
            )}
    }

    // MARK: - 감정 유형 TOP N
    static func topMoods(from items: [Item], limit: Int = 3) -> [MoodFrequency] {
        let total = max(items.count, 1)
        var counts: [String: Int] = [:]

        for item in items {
            let mood = item.mood == "기타" ? item.customMood : item.mood
            guard !mood.isEmpty else { continue }
            counts[mood, default: 0] += 1
        }

        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { MoodFrequency(
                mood: $0.key,
                count: $0.value,
                percentage: Double($0.value) / Double(total) * 100
            )}
    }

    // MARK: - 강도 추이 (일별 평균)
    static func intensityTrend(from items: [Item]) -> [IntensityTrend] {
        let calendar = Calendar.current
        var dailyIntensities: [Date: [Int]] = [:]

        for item in items {
            let day = calendar.startOfDay(for: item.timestamp)
            dailyIntensities[day, default: []].append(item.intensity)
        }

        return dailyIntensities.keys.sorted().map { date in
            let intensities = dailyIntensities[date]!
            let avg = Double(intensities.reduce(0, +)) / Double(intensities.count)
            return IntensityTrend(date: date, averageIntensity: avg)
        }
    }

    // MARK: - 전체 분석 조합
    static func analyze(items: [Item]) -> EmotionPatternAnalysis {
        let dayFreqs = dayOfWeekFrequencies(from: items)
        let timePatterns = timeOfDayPatterns(from: items)
        let reasons = topReasons(from: items)
        let moods = topMoods(from: items)
        let trend = intensityTrend(from: items)
        let avgIntensity = items.isEmpty ? 0.0 :
            Double(items.map(\.intensity).reduce(0, +)) / Double(items.count)

        let peakDay = dayFreqs.max(by: { $0.count < $1.count })
        let peakTime = timePatterns.max(by: { $0.count < $1.count })

        return EmotionPatternAnalysis(
            dayOfWeekFrequencies: dayFreqs,
            timeOfDayPatterns: timePatterns,
            topReasons: reasons,
            topMoods: moods,
            intensityTrend: trend,
            totalRecords: items.count,
            averageIntensity: avgIntensity,
            peakDay: (peakDay?.count ?? 0) > 0 ? peakDay?.dayName : nil,
            peakTimeRange: (peakTime?.count ?? 0) > 0 ? peakTime?.hourRange : nil
        )
    }
}
