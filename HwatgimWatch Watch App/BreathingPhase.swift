//
//  BreathingPhase.swift
//  HwatgimWatch Watch App
//

import SwiftUI

enum BreathingPhase: String {
    case inhale = "들이마시세요"
    case hold = "잠시 멈추세요"
    case exhale = "내뱉으세요"
    case ready = "길게 눌러서 시작"
    case paused = "다시 눌러서 계속"

    var duration: Double {
        switch self {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        case .ready, .paused: return 0
        }
    }

    var durationLabel: String {
        switch self {
        case .inhale: return "4초간 들이마시기"
        case .hold: return "7초간 멈추기"
        case .exhale: return "8초간 내뱉기"
        case .ready, .paused: return ""
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .inhale, .hold: return 1.0
        case .exhale: return 0.6
        case .ready, .paused: return 0.6
        }
    }
}
