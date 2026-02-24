//
//  FoundationModelReportService.swift
//  Hwatgim
//
//  iOS 26+ Apple Foundation Models (온디바이스 LLM) 구현체
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct FoundationModelReportService: ReportServiceProtocol {
    var isAIEnabled: Bool { true }
    var serviceDescription: String { "Apple Intelligence AI 분석" }
    var accessTier: ReportAccessTier { .premiumAI }

    func generateReport(from items: [Item], period: ReportPeriod) async throws -> EmotionReport {
        guard items.count >= 3 else {
            throw ReportError.insufficientData(minimum: 3, current: items.count)
        }

        // 1) 통계 분석 (공용)
        let analysis = EmotionAnalyzer.analyze(items: items)

        // 2) NaturalLanguage 감성분석 (공용)
        let sentimentAnalyzer = SentimentAnalyzer()
        let detailTexts = items.compactMap { $0.detail.isEmpty ? nil : $0.detail }
        let sentiment = sentimentAnalyzer.analyzeSentiment(texts: detailTexts)

        // 3) AI 인사이트 생성
        let insight = await generateAIInsight(analysis: analysis, sentiment: sentiment)

        // 4) AI 맞춤 팁 생성
        let tips = await generateAITips(analysis: analysis)

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
            accessTier: .premiumAI
        )
    }

    // MARK: - AI Insight Generation

    private func generateAIInsight(
        analysis: EmotionPatternAnalysis,
        sentiment: SentimentResult?
    ) async -> NaturalLanguageInsight {
        #if os(iOS) && canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                guard SystemLanguageModel.default.isAvailable else {
                    return fallbackInsight(analysis: analysis)
                }

                let session = LanguageModelSession()
                let prompt = buildInsightPrompt(analysis: analysis, sentiment: sentiment)
                let response = try await session.respond(to: prompt)

                return parseInsightResponse(response.content, isAI: true)
            } catch {
                return fallbackInsight(analysis: analysis)
            }
        }
        #endif
        return fallbackInsight(analysis: analysis)
    }

    private func generateAITips(analysis: EmotionPatternAnalysis) async -> [EmotionManagementTip] {
        #if os(iOS) && canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                guard SystemLanguageModel.default.isAvailable else {
                    return EmotionTipsProvider.matchTips(for: analysis)
                }

                let session = LanguageModelSession()
                let prompt = buildTipsPrompt(analysis: analysis)
                let response = try await session.respond(to: prompt)

                return parseTipsResponse(response.content)
            } catch {
                return EmotionTipsProvider.matchTips(for: analysis)
            }
        }
        #endif
        return EmotionTipsProvider.matchTips(for: analysis)
    }

    // MARK: - Prompt Building

    private func buildInsightPrompt(
        analysis: EmotionPatternAnalysis,
        sentiment: SentimentResult?
    ) -> String {
        var prompt = """
        당신은 따뜻하고 공감적인 감정 관리 전문가입니다.
        다음은 사용자의 분노 감정 기록 분석 데이터입니다.
        이 데이터를 바탕으로 따뜻한 어조로 인사이트를 제공해주세요.

        기간 내 총 기록: \(analysis.totalRecords)건
        평균 분노 강도: \(String(format: "%.1f", analysis.averageIntensity))/5
        """

        if let peakDay = analysis.peakDay {
            prompt += "\n가장 화가 많은 요일: \(peakDay)요일"
        }
        if let peakTime = analysis.peakTimeRange {
            prompt += "\n가장 화가 많은 시간대: \(peakTime)"
        }

        let reasonsStr = analysis.topReasons.map { "\($0.reason)(\($0.count)건)" }.joined(separator: ", ")
        if !reasonsStr.isEmpty {
            prompt += "\n주요 분노 원인: \(reasonsStr)"
        }

        let moodsStr = analysis.topMoods.map { "\($0.mood)(\($0.count)건)" }.joined(separator: ", ")
        if !moodsStr.isEmpty {
            prompt += "\n주요 감정: \(moodsStr)"
        }

        if let sentiment = sentiment {
            prompt += "\n감성 분석 점수: \(String(format: "%.2f", sentiment.overallScore)) (\(sentiment.dominantEmotion))"
        }

        prompt += """


        다음 형식으로 한국어로 답변해주세요:
        [요약] 2-3문장의 전체 패턴 요약 (공감적이고 따뜻한 어조)
        [발견1] 첫 번째 주요 발견
        [발견2] 두 번째 주요 발견
        [발견3] 세 번째 주요 발견
        """

        return prompt
    }

    private func buildTipsPrompt(analysis: EmotionPatternAnalysis) -> String {
        let reasonsStr = analysis.topReasons.map(\.reason).joined(separator: ", ")
        return """
        감정 관리 전문가로서, 다음 분노 패턴에 맞는 실천 가능한 맞춤형 관리 팁 3가지를 제공해주세요.
        따뜻하고 격려하는 어조로 작성해주세요.

        주요 분노 원인: \(reasonsStr.isEmpty ? "다양함" : reasonsStr)
        평균 강도: \(String(format: "%.1f", analysis.averageIntensity))/5
        총 기록: \(analysis.totalRecords)건

        각 팁을 다음 형식으로 한국어로:
        [팁1] 제목 | 설명 (2문장 이내)
        [팁2] 제목 | 설명
        [팁3] 제목 | 설명
        """
    }

    // MARK: - Response Parsing

    private func parseInsightResponse(_ text: String, isAI: Bool) -> NaturalLanguageInsight {
        var summary = ""
        var findings: [String] = []

        let lines = text.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[요약]") {
                summary = trimmed.replacingOccurrences(of: "[요약]", with: "")
                    .trimmingCharacters(in: .whitespaces)
            } else if trimmed.contains("[발견") {
                let finding = trimmed.replacingOccurrences(
                    of: "\\[발견\\d*\\]",
                    with: "",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)
                if !finding.isEmpty {
                    findings.append(finding)
                }
            }
        }

        // 파싱 실패 시 전체를 요약으로 사용
        if summary.isEmpty { summary = text }

        return NaturalLanguageInsight(
            summary: summary,
            keyFindings: findings,
            isAIGenerated: isAI
        )
    }

    private func parseTipsResponse(_ text: String) -> [EmotionManagementTip] {
        var tips: [EmotionManagementTip] = []
        let icons = ["heart.fill", "brain.head.profile", "figure.walk"]

        let lines = text.components(separatedBy: "\n")
        var tipIndex = 0
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("[팁") {
                let content = trimmed.replacingOccurrences(
                    of: "\\[팁\\d*\\]",
                    with: "",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)

                let parts = content.components(separatedBy: "|")
                if parts.count >= 2 {
                    tips.append(EmotionManagementTip(
                        icon: icons[min(tipIndex, icons.count - 1)],
                        title: parts[0].trimmingCharacters(in: .whitespaces),
                        description: parts[1].trimmingCharacters(in: .whitespaces),
                        isPersonalized: true
                    ))
                    tipIndex += 1
                }
            }
        }

        // 파싱 실패 시 기본 팁으로 폴백
        return tips.isEmpty ? EmotionTipsProvider.defaultTips() : Array(tips.prefix(3))
    }

    private func fallbackInsight(analysis: EmotionPatternAnalysis) -> NaturalLanguageInsight {
        RuleBasedInsightGenerator.generate(from: analysis)
    }
}
