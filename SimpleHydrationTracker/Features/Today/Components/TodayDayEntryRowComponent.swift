//
//  TodayDayEntryRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct TodayDayEntryRowComponent: View {
    internal let entry: HydrationEntry
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(AppTheme.accent.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(selectedUnit.format(milliliters: entry.amountMilliliters))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(entry.consumedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

#if DEBUG
    #Preview {
        TodayDayEntryRowComponent(
            entry: HydrationEntry(
                id: UUID(),
                amountMilliliters: 350,
                consumedAt: Date(),
                source: .quickAdd
            ),
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
