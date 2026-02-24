//
//  EmotionTipsProvider.swift
//  Hwatgim
//

import Foundation

struct EmotionTipsProvider {

    /// 분석 결과에 맞는 맞춤 팁 매칭 (최대 3개)
    static func matchTips(for analysis: EmotionPatternAnalysis) -> [EmotionManagementTip] {
        var tips: [EmotionManagementTip] = []

        // 1) 주요 원인 기반 팁
        if let topReason = analysis.topReasons.first {
            tips.append(tipForReason(topReason.reason))
        }

        // 2) 강도 기반 팁
        tips.append(tipForIntensity(analysis.averageIntensity))

        // 3) 시간대 기반 팁
        if let peakTime = analysis.peakTimeRange {
            tips.append(tipForTimeOfDay(peakTime))
        } else {
            tips.append(generalActivityTip())
        }

        return Array(tips.prefix(3))
    }

    /// 기본 팁 세트
    static func defaultTips() -> [EmotionManagementTip] {
        [
            EmotionManagementTip(
                icon: "heart.fill",
                title: "깊은 호흡",
                description: "화가 날 때 4-7-8 호흡법을 시도해보세요. 4초 들이마시고, 7초 참고, 8초 내쉬면 마음이 차분해집니다.",
                isPersonalized: false
            ),
            EmotionManagementTip(
                icon: "pencil.and.list.clipboard",
                title: "감정 기록 습관",
                description: "꾸준한 기록이 감정 패턴을 이해하는 첫걸음입니다. 매일 한 번 감정을 돌아보는 시간을 가져보세요.",
                isPersonalized: false
            ),
            EmotionManagementTip(
                icon: "figure.walk",
                title: "몸으로 풀기",
                description: "분노의 에너지를 15분 빠르게 걷기로 전환해보세요. 신체 활동은 스트레스 호르몬을 자연스럽게 해소합니다.",
                isPersonalized: false
            ),
        ]
    }

    // MARK: - Private Matching Logic

    private static func tipForReason(_ reason: String) -> EmotionManagementTip {
        switch reason {
        case "사람":
            return EmotionManagementTip(
                icon: "person.2.fill",
                title: "관계 속 분노 다루기",
                description: "상대방의 의도와 내 해석 사이의 간극을 인식해보세요. 5분간 상대의 입장에서 상황을 떠올려보는 연습이 도움이 됩니다.",
                isPersonalized: false
            )
        case "업무":
            return EmotionManagementTip(
                icon: "briefcase.fill",
                title: "업무 스트레스 관리",
                description: "업무로 인한 분노는 경계 설정이 핵심입니다. 할 수 있는 것과 없는 것을 구분하고, 작은 성취에 집중해보세요.",
                isPersonalized: false
            )
        case "환경":
            return EmotionManagementTip(
                icon: "leaf.fill",
                title: "환경적 분노 줄이기",
                description: "통제할 수 없는 환경 요인에는 수용의 자세를, 바꿀 수 있는 것에는 작은 행동 변화를 시도해보세요.",
                isPersonalized: false
            )
        default:
            return EmotionManagementTip(
                icon: "sparkles",
                title: "나만의 분노 패턴 인식",
                description: "반복되는 분노 상황을 인식하는 것만으로도 큰 변화의 시작입니다. 기록을 꾸준히 이어가 보세요.",
                isPersonalized: false
            )
        }
    }

    private static func tipForIntensity(_ averageIntensity: Double) -> EmotionManagementTip {
        if averageIntensity >= 4.0 {
            return EmotionManagementTip(
                icon: "heart.fill",
                title: "강한 분노를 위한 즉각 진정법",
                description: "4-7-8 호흡법을 실천해보세요. 4초 들이마시고, 7초 참고, 8초 내쉬는 것을 3회 반복하면 심박수가 안정됩니다.",
                isPersonalized: false
            )
        } else if averageIntensity >= 2.5 {
            return EmotionManagementTip(
                icon: "brain.head.profile",
                title: "감정 인식 연습",
                description: "분노가 올라올 때 '나는 지금 ~때문에 ~한 감정을 느끼고 있다'라고 말로 표현해보세요. 이름을 붙이면 감정이 줄어듭니다.",
                isPersonalized: false
            )
        } else {
            return EmotionManagementTip(
                icon: "hand.thumbsup.fill",
                title: "잘 관리하고 계세요!",
                description: "분노 강도가 낮게 유지되고 있어요. 지금처럼 감정을 인식하고 기록하는 습관을 계속 이어가세요.",
                isPersonalized: false
            )
        }
    }

    private static func tipForTimeOfDay(_ peakTime: String) -> EmotionManagementTip {
        if peakTime.contains("새벽") {
            return EmotionManagementTip(
                icon: "moon.fill",
                title: "새벽 감정 관리",
                description: "새벽에 감정이 격해지는 경향이 있어요. 충분한 수면과 규칙적인 생활 리듬이 감정 안정에 도움이 됩니다.",
                isPersonalized: false
            )
        } else if peakTime.contains("아침") {
            return EmotionManagementTip(
                icon: "sun.rise.fill",
                title: "아침 마인드 세팅",
                description: "출근 전 5분 명상이나 가벼운 스트레칭으로 하루를 시작해보세요. 아침의 마음 상태가 하루를 좌우합니다.",
                isPersonalized: false
            )
        } else if peakTime.contains("오후") {
            return EmotionManagementTip(
                icon: "cup.and.saucer.fill",
                title: "오후 리프레시",
                description: "오후에 감정이 격해지기 쉬워요. 점심 후 10분 산책이나 짧은 휴식으로 에너지를 리셋해보세요.",
                isPersonalized: false
            )
        } else {
            return EmotionManagementTip(
                icon: "moon.stars.fill",
                title: "저녁 감정 정리",
                description: "밤에 감정이 격해지는 패턴이 있어요. 취침 1시간 전 디지털 디톡스와 가벼운 스트레칭을 추천합니다.",
                isPersonalized: false
            )
        }
    }

    private static func generalActivityTip() -> EmotionManagementTip {
        EmotionManagementTip(
            icon: "figure.walk",
            title: "몸으로 풀기",
            description: "분노 에너지를 15분 빠르게 걷기나 계단 오르기로 전환해보세요. 신체 활동은 아드레날린을 자연스럽게 해소합니다.",
            isPersonalized: false
        )
    }
}
