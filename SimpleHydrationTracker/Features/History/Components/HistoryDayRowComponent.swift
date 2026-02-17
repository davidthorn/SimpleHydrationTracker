//
//  HistoryDayRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SimpleFramework
import SwiftUI

internal struct HistoryDayRowComponent: View {
    internal let summary: HistoryDaySummary
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

            HistoryDayMiniChartComponent(
                buckets: summary.intakeBuckets,
                tint: goalStatusColor
            )

            HStack(spacing: 8) {
                statPill(
                    title: "Avg / hour",
                    value: averagePerHourText
                )
                statPill(
                    title: "Avg / entry",
                    value: averagePerEntryText
                )
                statPill(
                    title: "Peak",
                    value: peakText
                )
            }
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary.date.formatted(date: .complete, time: .omitted))
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Opens day detail.")
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
        return didReachGoal ? AppTheme.success : AppTheme.warning
    }

    private var averagePerHourText: String {
        guard let averageMillilitersPerHour = summary.averageMillilitersPerHour else {
            return "n/a"
        }
        return selectedUnit.format(milliliters: averageMillilitersPerHour)
    }

    private var averagePerEntryText: String {
        guard let averageMillilitersPerEntry = summary.averageMillilitersPerEntry else {
            return "n/a"
        }
        return selectedUnit.format(milliliters: averageMillilitersPerEntry)
    }

    private var peakText: String {
        guard
            let peakBucketStart = summary.peakBucketStart,
            let peakBucketMilliliters = summary.peakBucketMilliliters
        else {
            return "n/a"
        }

        let timeText = peakBucketStart.formatted(date: .omitted, time: .shortened)
        let volumeText = selectedUnit.format(milliliters: peakBucketMilliliters)
        return "\(timeText) \(volumeText)"
    }

    private var accessibilityValue: String {
        var parts: [String] = []
        parts.append("Total \(selectedUnit.format(milliliters: summary.totalMilliliters)).")
        parts.append("\(summary.entryCount) entries.")
        parts.append(goalStatusText + ".")

        if summary.averageMillilitersPerHour != nil {
            parts.append("Average per hour \(averagePerHourText).")
        }
        if summary.averageMillilitersPerEntry != nil {
            parts.append("Average per entry \(averagePerEntryText).")
        }

        return parts.joined(separator: " ")
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(AppTheme.muted)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.65))
        )
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
