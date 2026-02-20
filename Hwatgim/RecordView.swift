//
//  RecordView.swift
//  Hwatgim
//

import SwiftUI
import SwiftData

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason: String? = nil
    @State private var customReasonText: String = ""
    @State private var selectedMood: String? = nil
    @State private var customMoodText: String = ""
    @State private var detailText: String = ""
    @State private var selectedIntensity: Int = 3
    @FocusState private var focusedField: FocusField?

    private let reasons = ["사람", "업무", "환경"]
    private let moods = ["짜증", "억울함", "답답함", "분노"]

    private enum FocusField {
        case customReason
        case customMood
        case detail
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }

            VStack(alignment: .leading, spacing: 0) {
                // 뒤로가기 버튼
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        reasonSection
                        moodSection
                        intensitySection
                        detailSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }

                completeButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Reason Section
    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("무엇 때문에 화가 났나요?")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                .foregroundColor(.white)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(reasons, id: \.self) { reason in
                    SelectionChip(
                        title: reason,
                        isSelected: selectedReason == reason
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if selectedReason == reason {
                                selectedReason = nil
                            } else {
                                selectedReason = reason
                                customReasonText = ""
                            }
                        }
                    }
                }

                // 기타 칩
                SelectionChip(
                    title: "기타",
                    isSelected: selectedReason == "기타"
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if selectedReason == "기타" {
                            selectedReason = nil
                            customReasonText = ""
                        } else {
                            selectedReason = "기타"
                            focusedField = .customReason
                        }
                    }
                }
            }

            // 기타 입력 필드
            if selectedReason == "기타" {
                customTextField(
                    text: $customReasonText,
                    placeholder: "직접 입력해주세요",
                    focus: .customReason
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Mood Section
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("지금 기분은 어떤가요?")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                .foregroundColor(.white)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(moods, id: \.self) { mood in
                    SelectionChip(
                        title: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if selectedMood == mood {
                                selectedMood = nil
                            } else {
                                selectedMood = mood
                                customMoodText = ""
                            }
                        }
                    }
                }

                // 기타 칩
                SelectionChip(
                    title: "기타",
                    isSelected: selectedMood == "기타"
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if selectedMood == "기타" {
                            selectedMood = nil
                            customMoodText = ""
                        } else {
                            selectedMood = "기타"
                            focusedField = .customMood
                        }
                    }
                }
            }

            // 기타 입력 필드
            if selectedMood == "기타" {
                customTextField(
                    text: $customMoodText,
                    placeholder: "직접 입력해주세요",
                    focus: .customMood
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Custom TextField
    private func customTextField(text: Binding<String>, placeholder: String, focus: FocusField) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal, 16)
            }

            TextField("", text: text)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .focused($focusedField, equals: focus)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Intensity Section
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("얼마나 화가 나나요?")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedIntensity = level
                        }
                    } label: {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28))
                            .foregroundColor(level <= selectedIntensity
                                ? Color(red: 0.9, green: 0.35, blue: 0.25)
                                : Color.white.opacity(0.15))
                    }
                }
            }
        }
    }

    // MARK: - Detail Section
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("더 이야기하고 싶은 것이 있나요?")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 20))
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .frame(minHeight: 140)

                if detailText.isEmpty && focusedField != .detail {
                    Text("자유롭게 적어보세요...")
                        .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $detailText)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minHeight: 140)
                    .focused($focusedField, equals: .detail)
            }
        }
    }

    // MARK: - Complete Button
    private var completeButton: some View {
        Button(action: saveRecord) {
            Text("기록 완료")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 17))
                .foregroundColor(.white.opacity(hasSelection ? 1.0 : 0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hasSelection ? Color(red: 0.75, green: 0.2, blue: 0.2) : Color.white.opacity(0.1))
                )
        }
        .disabled(!hasSelection)
    }

    private var hasSelection: Bool {
        selectedReason != nil || selectedMood != nil || !detailText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveRecord() {
        let newItem = Item(
            timestamp: Date(),
            reason: selectedReason ?? "",
            mood: selectedMood ?? "",
            detail: detailText.trimmingCharacters(in: .whitespacesAndNewlines),
            intensity: selectedIntensity,
            customReason: selectedReason == "기타" ? customReasonText.trimmingCharacters(in: .whitespacesAndNewlines) : "",
            customMood: selectedMood == "기타" ? customMoodText.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        )
        modelContext.insert(newItem)
        dismiss()
    }
}

// MARK: - Selection Chip Component
struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 16))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color(red: 0.75, green: 0.2, blue: 0.2) : Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color(red: 0.75, green: 0.2, blue: 0.2) : Color.white.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

#Preview {
    RecordView()
        .modelContainer(for: Item.self, inMemory: true)
}
