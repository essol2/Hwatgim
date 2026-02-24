//
//  ReportData.swift
//  Hwatgim
//

import Foundation

// MARK: - Report Period
enum ReportPeriod: String, CaseIterable {
    case weekly = "주간"
    case monthly = "월간"

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .weekly:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            return (start, now)
        case .monthly:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            return (start, now)
        }
    }
}

// MARK: - Report Access Tier (결제 등급)
enum ReportAccessTier: Equatable {
    case free           // 미결제 (페이월 활성 시)
    case basicAnalysis  // iOS <26, 규칙 기반 분석
    case premiumAI      // iOS 26+, 풀 AI 분석
}

// MARK: - Emotion Pattern Data
struct DayOfWeekFrequency: Identifiable {
    let id = UUID()
    let dayName: String          // "월", "화", ...
    let dayIndex: Int            // 0=Mon, 6=Sun
    let count: Int
    let averageIntensity: Double
}

struct TimeOfDayPattern: Identifiable {
    let id = UUID()
    let hourRange: String        // "새벽 (0-6시)" 등
    let count: Int
    let percentage: Double
}

struct ReasonFrequency: Identifiable {
    let id = UUID()
    let reason: String
    let count: Int
    let percentage: Double
}

struct MoodFrequency: Identifiable {
    let id = UUID()
    let mood: String
    let count: Int
    let percentage: Double
}

struct IntensityTrend: Identifiable {
    let id = UUID()
    let date: Date
    let averageIntensity: Double
}

struct SentimentResult {
    let overallScore: Double     // -1.0 ~ 1.0
    let dominantEmotion: String
    let confidence: Double
}

// MARK: - Assembled Analysis
struct EmotionPatternAnalysis {
    let dayOfWeekFrequencies: [DayOfWeekFrequency]
    let timeOfDayPatterns: [TimeOfDayPattern]
    let topReasons: [ReasonFrequency]
    let topMoods: [MoodFrequency]
    let intensityTrend: [IntensityTrend]
    let totalRecords: Int
    let averageIntensity: Double
    let peakDay: String?
    let peakTimeRange: String?
}

// MARK: - Natural Language Insight
struct NaturalLanguageInsight {
    let summary: String
    let keyFindings: [String]
    let isAIGenerated: Bool
}

// MARK: - Emotion Management Tip
struct EmotionManagementTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let isPersonalized: Bool
}

// MARK: - Complete Report
struct EmotionReport {
    let period: ReportPeriod
    let generatedAt: Date
    let dateRangeStart: Date
    let dateRangeEnd: Date
    let patternAnalysis: EmotionPatternAnalysis
    let insight: NaturalLanguageInsight
    let tips: [EmotionManagementTip]
    let sentimentResult: SentimentResult?
    let accessTier: ReportAccessTier
}

// MARK: - Shareable Summary (추후 전문가 상담 공유용)
struct ShareableReportSummary: Codable {
    let periodDescription: String
    let totalRecords: Int
    let averageIntensity: Double
    let topReasons: [String]
    let topMoods: [String]
    let peakDay: String?
    let peakTimeRange: String?
    let insightSummary: String
    let generatedAt: Date
}

// MARK: - Report Error
enum ReportError: LocalizedError {
    case insufficientData(minimum: Int, current: Int)
    case generationFailed(underlying: Error)
    case aiUnavailable

    var errorDescription: String? {
        switch self {
        case .insufficientData(let min, let current):
            return "분석을 위해 최소 \(min)개의 기록이 필요합니다. (현재 \(current)개)"
        case .generationFailed(let error):
            return "보고서 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
        case .aiUnavailable:
            return "AI 기능을 사용할 수 없습니다."
        }
    }
}
