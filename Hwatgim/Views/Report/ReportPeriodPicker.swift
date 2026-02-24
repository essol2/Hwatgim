//
//  ReportPeriodPicker.swift
//  Hwatgim
//

import SwiftUI

struct ReportPeriodPicker: View {
    @Binding var selectedPeriod: ReportPeriod

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ReportPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.custom("HakgyoansimDunggeunmisoOTF-B", size: 15))
                        .foregroundColor(selectedPeriod == period ? .white : .white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedPeriod == period
                                    ? Color(red: 0.9, green: 0.35, blue: 0.25).opacity(0.3)
                                    : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
    }
}
