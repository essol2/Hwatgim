//
//  SettingsView.swift
//  Hwatgim
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("userName") private var userName = "은솔"
    @AppStorage("userRole") private var userRole = "직장인"

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Header
                    headerSection

                    // MARK: - Profile Card
                    profileCard

                    // MARK: - Settings Items
                    VStack(spacing: 12) {
                        notificationRow
                        darkModeRow
                        appInfoRow
                        contactRow
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("설정")
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 28))
                .foregroundColor(.white)

            Text("앱 설정을 관리하세요")
                .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.bottom, 8)
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(red: 0.35, green: 0.12, blue: 0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.25))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 18))
                    .foregroundColor(.white)

                Text(userRole)
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Notification Row
    private var notificationRow: some View {
        settingsRow(
            icon: "bell",
            title: "알림 설정",
            trailing: {
                Text(notificationEnabled ? "켜짐" : "꺼짐")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        )
    }

    // MARK: - Dark Mode Row
    private var darkModeRow: some View {
        settingsRow(
            icon: "moon",
            title: "다크 모드",
            trailing: {
                Text("항상")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        )
    }

    // MARK: - App Info Row
    private var appInfoRow: some View {
        settingsRow(
            icon: "info.circle",
            title: "앱 정보",
            trailing: {
                Text("v1.0.0")
                    .font(.custom("HakgyoansimDunggeunmisoOTF-R", size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        )
    }

    // MARK: - Contact Row
    private var contactRow: some View {
        settingsRow(
            icon: "envelope",
            title: "문의하기",
            trailing: { EmptyView() }
        )
    }

    // MARK: - Generic Settings Row
    private func settingsRow<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 24)

            Text(title)
                .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 16))
                .foregroundColor(.white)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
    }
}

#Preview {
    SettingsView()
}
