//
//  ReportView.swift
//  Hwatgim
//

import SwiftUI
import SwiftData

struct ReportView: View {
    @Query(sort: \Item.timestamp, order: .reverse) private var allItems: [Item]

    @State private var selectedPeriod: ReportPeriod = .weekly
    @State private var report: EmotionReport?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let reportService: ReportServiceProtocol = ReportServiceFactory.create()
    private let paywallGate: PaywallGateProtocol = PaywallGate()

    private let minimumRecords = 3

    /// 선택 기간에 맞는 기록만 필터
    private var filteredItems: [Item] {
        let range = selectedPeriod.dateRange
        return allItems.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
    }

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - 헤더
                    headerSection

                    // MARK: - 기간 선택
                    ReportPeriodPicker(selectedPeriod: $selectedPeriod)

                    // MARK: - 콘텐츠
                    if !paywallGate.canAccessReport() {
                        paywallBlockView
                    } else if filteredItems.count < minimumRecords {
                        ReportEmptyStateView(
                            currentCount: filteredItems.count,
                            minimumRequired: minimumRecords
                        )
                        .frame(minHeight: 350)
                    } else if isLoading {
                        ReportLoadingView(isAI: reportService.isAIEnabled)
                            .frame(minHeight: 350)
                    } else if let report = report {
                        reportContent(report)
                    } else if let errorMessage = errorMessage {
                        errorView(errorMessage)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .task(id: selectedPeriod) {
            await generateReport()
        }
        .onChange(of: allItems.count) {
            Task {
                await generateReport()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text("AI 분노 보고서")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 28))
                    .foregroundColor(.white)

                if reportService.isAIEnabled {
                    Image(systemName: "brain")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
                }
            }

            Text(reportService.serviceDescription)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Report Content

    @ViewBuilder
    private func reportContent(_ report: EmotionReport) -> some View {
        // iOS <26 안내 배너
        ReportUpsellBanner(tier: report.accessTier)

        // 1) 감정 패턴 분석
        EmotionPatternCard(analysis: report.patternAnalysis)

        // 2) 인사이트
        InsightCard(
            insight: report.insight,
            sentiment: report.sentimentResult
        )

        // 3) 감정 관리 팁
        EmotionTipsCard(tips: report.tips)

        // 4) 추후 전문가 상담 배너 자리
        expertConsultationPlaceholder

        // 5) 보고서 생성 정보
        reportFooter(report)
    }

    // MARK: - Paywall Block

    private var paywallBlockView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: 8) {
                Text("프리미엄 기능")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                    .foregroundColor(.white)

                Text("감정 분석 보고서를 이용하려면\n구독이 필요합니다")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            // TODO: 구독 버튼 추가
            // Button("구독하기") { }

            Spacer()
        }
        .frame(minHeight: 350)
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.6))

            Text(message)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                Task { await generateReport() }
            } label: {
                Text("다시 시도")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.3))
                    )
            }

            Spacer()
        }
        .frame(minHeight: 300)
    }

    // MARK: - Expert Consultation Placeholder

    private var expertConsultationPlaceholder: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 4) {
                Text("전문가 상담 연결")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 14))
                    .foregroundColor(.white.opacity(0.5))

                Text("곧 만나요!")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }

            Spacer()

            Text("준비중")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                .foregroundColor(.white.opacity(0.3))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.06))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Report Footer

    private func reportFooter(_ report: EmotionReport) -> some View {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M.d HH:mm"

        return VStack(spacing: 4) {
            Text("보고서 생성: \(formatter.string(from: report.generatedAt))")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                .foregroundColor(.white.opacity(0.2))

            Text(report.accessTier == .premiumAI
                ? "Apple Intelligence 온디바이스 AI 분석"
                : "통계 + NaturalLanguage 기반 분석")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 11))
                .foregroundColor(.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Report Generation

    private func generateReport() async {
        guard paywallGate.canAccessReport() else { return }
        guard filteredItems.count >= minimumRecords else {
            report = nil
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let generatedReport = try await reportService.generateReport(
                from: filteredItems,
                period: selectedPeriod
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                report = generatedReport
                isLoading = false
            }
        } catch let error as ReportError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = "예기치 않은 오류가 발생했습니다."
            isLoading = false
        }
    }
}

#Preview {
    ReportView()
        .modelContainer(for: Item.self, inMemory: true)
}
