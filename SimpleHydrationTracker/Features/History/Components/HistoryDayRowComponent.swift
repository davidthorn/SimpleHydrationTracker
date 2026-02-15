//
//  HistoryDayRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct HistoryDayRowComponent: View {
    internal let summary: HistoryDaySummary
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(summary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Image(systemName: goalStatusIconName)
                        .font(.caption.weight(.semibold))
                    Text(goalStatusText)
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(goalStatusColor)

                Text("\(summary.entryCount) entries")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            Text(selectedUnit.format(milliliters: summary.totalMilliliters))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(goalStatusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(goalStatusColor.opacity(0.12))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(goalStatusColor.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var goalStatusText: String {
        guard let didReachGoal = summary.didReachGoal else {
            return "No Goal"
        }
        return didReachGoal ? "Goal Reached" : "Goal Missed"
    }

    private var goalStatusIconName: String {
        guard let didReachGoal = summary.didReachGoal else {
            return "target"
        }
        return didReachGoal ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
    }

    private var goalStatusColor: Color {
        guard let didReachGoal = summary.didReachGoal else {
            return AppTheme.accent
        }
        return didReachGoal ? .green : .orange
    }
}

#if DEBUG
    #Preview {
        HistoryDayRowComponent(
            summary: HistoryDaySummary(
                dayID: HydrationDayIdentifier(value: Date()),
                date: Date(),
                totalMilliliters: 1800,
                entryCount: 6
            ),
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
