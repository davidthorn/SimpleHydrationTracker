//
//  HistorySummaryCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistorySummaryCardComponent: View {
    internal let date: Date
    internal let totalMilliliters: Int
    internal let entryCount: Int
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 10) {
                historyMetric(title: "Total", value: selectedUnit.format(milliliters: totalMilliliters))
                historyMetric(title: "Entries", value: "\(entryCount)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private func historyMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
    #Preview {
        HistorySummaryCardComponent(
            date: Date(),
            totalMilliliters: 2050,
            entryCount: 7,
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
