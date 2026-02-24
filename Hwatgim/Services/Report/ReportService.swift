//
//  ReportService.swift
//  Hwatgim
//

import Foundation

// MARK: - Protocol
protocol ReportServiceProtocol {
    func generateReport(from items: [Item], period: ReportPeriod) async throws -> EmotionReport
    var isAIEnabled: Bool { get }
    var serviceDescription: String { get }
    var accessTier: ReportAccessTier { get }
}

// MARK: - Factory
struct ReportServiceFactory {
    static func create() -> ReportServiceProtocol {
        if #available(iOS 26.0, *) {
            return FoundationModelReportService()
        } else {
            return RuleBasedReportService()
        }
    }
}

// MARK: - Template-Based Insight Generator (공용)
struct RuleBasedInsightGenerator {
    static func generate(from analysis: EmotionPatternAnalysis) -> NaturalLanguageInsight {
        var summaryParts: [String] = []
        var findings: [String] = []

        // 요약
        summaryParts.append("지난 기간 동안 총 \(analysis.totalRecords)건의 감정을 기록하셨어요.")
        let intensityStr = String(format: "%.1f", analysis.averageIntensity)
        summaryParts.append("평균 분노 강도는 \(intensityStr)점이에요.")

        // 발견 1: 가장 화가 많은 요일
        if let peakDay = analysis.peakDay {
            findings.append("\(peakDay)요일에 분노가 가장 많이 발생했어요.")
        }

        // 발견 2: 주요 원인
        if let topReason = analysis.topReasons.first {
            let pctStr = String(format: "%.0f", topReason.percentage)
            findings.append("'\(topReason.reason)' 때문에 가장 많이 화가 났어요. (\(topReason.count)건, \(pctStr)%)")
        }

        // 발견 3: 피크 시간대
        if let peakTime = analysis.peakTimeRange {
            findings.append("\(peakTime) 시간대에 감정이 가장 격해졌어요.")
        }

        // 발견 4: 주요 감정
        if let topMood = analysis.topMoods.first {
            findings.append("가장 자주 느낀 감정은 '\(topMood.mood)'이에요.")
        }

        return NaturalLanguageInsight(
            summary: summaryParts.joined(separator: " "),
            keyFindings: findings,
            isAIGenerated: false
        )
    }
}
