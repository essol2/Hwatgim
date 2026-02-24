//
//  SentimentAnalyzer.swift
//  Hwatgim
//

import Foundation
import NaturalLanguage

struct SentimentAnalyzer {

    /// 여러 텍스트의 감성 분석 종합
    func analyzeSentiment(texts: [String]) -> SentimentResult? {
        guard !texts.isEmpty else { return nil }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        var scores: [Double] = []

        for text in texts {
            tagger.string = text
            let (sentiment, _) = tagger.tag(
                at: text.startIndex,
                unit: .paragraph,
                scheme: .sentimentScore
            )
            if let sentimentValue = sentiment?.rawValue,
               let score = Double(sentimentValue) {
                scores.append(score)
            }
        }

        guard !scores.isEmpty else { return nil }

        let averageScore = scores.reduce(0, +) / Double(scores.count)
        let dominantEmotion = classifyEmotion(score: averageScore)
        let confidence = abs(averageScore)

        return SentimentResult(
            overallScore: averageScore,
            dominantEmotion: dominantEmotion,
            confidence: confidence
        )
    }

    /// 감성 점수를 한국어 감정 라벨로 분류
    private func classifyEmotion(score: Double) -> String {
        switch score {
        case ..<(-0.5):
            return "매우 부정적"
        case -0.5..<(-0.1):
            return "부정적"
        case -0.1...0.1:
            return "중립적"
        case 0.1..<0.5:
            return "다소 긍정적"
        default:
            return "긍정적"
        }
    }

    /// 개별 텍스트에서 핵심 명사 추출
    func extractKeyNouns(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var nouns: [String] = []
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass
        ) { tag, range in
            if tag == .noun {
                let word = String(text[range])
                if word.count > 1 { // 1글자 조사/접미사 제외
                    nouns.append(word)
                }
            }
            return true
        }
        return nouns
    }
}
