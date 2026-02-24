//
//  RuleBasedReportService.swift
//  Hwatgim
//
//  iOS 17+ 규칙 기반 + NaturalLanguage 감성분석 구현체
//

import Foundation

struct RuleBasedReportService: ReportServiceProtocol {
    var isAIEnabled: Bool { false }
    var serviceDescription: String { "통계 기반 분석" }
    var accessTier: ReportAccessTier { .basicAnalysis }

    func generateReport(from items: [Item], period: ReportPeriod) async throws -> EmotionReport {
        guard items.count >= 3 else {
            throw ReportError.insufficientData(minimum: 3, current: items.count)
        }

        // 1) 통계 분석
        let analysis = EmotionAnalyzer.analyze(items: items)

        // 2) NaturalLanguage 감성분석
        let sentimentAnalyzer = SentimentAnalyzer()
        let detailTexts = items.compactMap { $0.detail.isEmpty ? nil : $0.detail }
        let sentiment = sentimentAnalyzer.analyzeSentiment(texts: detailTexts)

        // 3) 템플릿 기반 인사이트
        let insight = RuleBasedInsightGenerator.generate(from: analysis)

        // 4) 매칭된 팁
        let tips = EmotionTipsProvider.matchTips(for: analysis)

        let range = period.dateRange
        return EmotionReport(
            period: period,
            generatedAt: Date(),
            dateRangeStart: range.start,
            dateRangeEnd: range.end,
            patternAnalysis: analysis,
            insight: insight,
            tips: tips,
            sentimentResult: sentiment,
            accessTier: .basicAnalysis
        )
    }
}
