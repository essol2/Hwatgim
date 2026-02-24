//
//  PaywallGate.swift
//  Hwatgim
//
//  결제 게이트 - 추후 StoreKit 연동 시 활성화
//

import Foundation

// MARK: - Protocol
protocol PaywallGateProtocol {
    var isPaywallEnabled: Bool { get }
    var currentTier: ReportAccessTier { get }
    func canAccessReport() -> Bool
    func canAccessAIFeatures() -> Bool
}

// MARK: - Implementation
final class PaywallGate: PaywallGateProtocol {

    /// 페이월 활성화 플래그 - true로 변경 시 결제 필요
    /// 추후 StoreKit 2 연동 시 이 값을 구독 상태에 따라 변경
    let isPaywallEnabled: Bool = false

    var currentTier: ReportAccessTier {
        if isPaywallEnabled {
            // TODO: StoreKit 2의 Transaction.currentEntitlements 확인
            // 결제 미완료 시 .free 반환
            return .free
        }

        // 페이월 비활성 → OS 기반 무료 접근
        if #available(iOS 26.0, *) {
            return .premiumAI
        }
        return .basicAnalysis
    }

    func canAccessReport() -> Bool {
        if !isPaywallEnabled { return true }
        return currentTier != .free
    }

    func canAccessAIFeatures() -> Bool {
        return currentTier == .premiumAI
    }
}
