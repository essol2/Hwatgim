//
//  HwatgimWidget.swift
//  HwatgimWidget
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct HwatgimProvider: TimelineProvider {
    func placeholder(in context: Context) -> HwatgimEntry {
        HwatgimEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (HwatgimEntry) -> Void) {
        completion(HwatgimEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HwatgimEntry>) -> Void) {
        let entry = HwatgimEntry(date: Date())
        // 위젯은 정적이므로 1시간 후 갱신
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct HwatgimEntry: TimelineEntry {
    let date: Date
}

// MARK: - Widget Views

/// Small (2×2) 위젯
struct HwatgimWidgetSmallView: View {
    var entry: HwatgimEntry

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                // SOS 텍스트
                Text("SOS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.3),
                                Color(red: 0.9, green: 0.2, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.6), radius: 8, x: 0, y: 0)

                // 호흡 안내 텍스트
                Text("숨 고르기")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            // 모서리 장식 — 은은한 원형 글로우
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.9, green: 0.2, blue: 0.15).opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .offset(y: 20)
        }
    }
}

/// Large (4×4) 위젯
struct HwatgimWidgetLargeView: View {
    var entry: HwatgimEntry

    var body: some View {
        ZStack {
            // 배경 글로우
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.9, green: 0.2, blue: 0.15).opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)

            VStack(spacing: 16) {
                Spacer()

                // SOS 텍스트 — 크게
                Text("SOS")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.3),
                                Color(red: 0.9, green: 0.2, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.6), radius: 12, x: 0, y: 0)

                // 호흡 원 시각 표현
                ZStack {
                    Circle()
                        .stroke(
                            Color(red: 0.6, green: 0.15, blue: 0.15).opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.12, blue: 0.12).opacity(0.8),
                                    Color(red: 0.25, green: 0.08, blue: 0.08).opacity(0.4)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 76, height: 76)

                    Image(systemName: "wind")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                // 안내 텍스트
                VStack(spacing: 6) {
                    Text("숨 고르기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))

                    Text("탭하여 호흡 시작")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()
            }
        }
    }
}

// MARK: - Medium (2×4) 위젯 — 중간 사이즈 대응
struct HwatgimWidgetMediumView: View {
    var entry: HwatgimEntry

    var body: some View {
        ZStack {
            // 배경 글로우
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.9, green: 0.2, blue: 0.15).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: -60)

            HStack(spacing: 20) {
                // 왼쪽: SOS
                VStack(spacing: 6) {
                    Text("SOS")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.3),
                                    Color(red: 0.9, green: 0.2, blue: 0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.6), radius: 10, x: 0, y: 0)
                }

                // 구분선
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 1, height: 40)

                // 오른쪽: 안내
                VStack(alignment: .leading, spacing: 4) {
                    Text("숨 고르기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))

                    Text("탭하여 호흡 시작")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
        }
    }
}

// MARK: - Widget Configuration

struct HwatgimWidget: Widget {
    let kind: String = "HwatgimWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HwatgimProvider()) { entry in
            Group {
                if #available(iOSApplicationExtension 17.0, *) {
                    HwatgimWidgetEntryView(entry: entry)
                        .containerBackground(for: .widget) {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.05, blue: 0.05),
                                    Color(red: 0.18, green: 0.06, blue: 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                } else {
                    HwatgimWidgetEntryView(entry: entry)
                }
            }
            .widgetURL(URL(string: "hwatgim://breathing"))
        }
        .configurationDisplayName("홧김 SOS")
        .description("숨 고르기 호흡 운동을 바로 시작합니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Entry View (사이즈별 분기)

struct HwatgimWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: HwatgimEntry

    var body: some View {
        switch family {
        case .systemSmall:
            HwatgimWidgetSmallView(entry: entry)
        case .systemMedium:
            HwatgimWidgetMediumView(entry: entry)
        case .systemLarge:
            HwatgimWidgetLargeView(entry: entry)
        default:
            HwatgimWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    HwatgimWidget()
} timeline: {
    HwatgimEntry(date: Date())
}

#Preview("Medium", as: .systemMedium) {
    HwatgimWidget()
} timeline: {
    HwatgimEntry(date: Date())
}

#Preview("Large", as: .systemLarge) {
    HwatgimWidget()
} timeline: {
    HwatgimEntry(date: Date())
}
