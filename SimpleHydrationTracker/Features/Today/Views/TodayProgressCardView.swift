//
//  TodayProgressCardView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework

internal struct TodayProgressCardView: View {
    private let consumedMilliliters: Int
    private let goalMilliliters: Int
    private let remainingMilliliters: Int
    private let progress: Double
    private let selectedUnit: SettingsVolumeUnit

    internal init(
        consumedMilliliters: Int,
        goalMilliliters: Int,
        remainingMilliliters: Int,
        progress: Double,
        selectedUnit: SettingsVolumeUnit
    ) {
        self.consumedMilliliters = consumedMilliliters
        self.goalMilliliters = goalMilliliters
        self.remainingMilliliters = remainingMilliliters
        self.progress = progress
        self.selectedUnit = selectedUnit
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Hydration")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(progressLabel)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(progressTint)

            HStack(spacing: 12) {
                todayMetric(title: "Consumed", value: selectedUnit.format(milliliters: consumedMilliliters))
                todayMetric(title: "Goal", value: goalText)
                todayMetric(title: "Remaining", value: selectedUnit.format(milliliters: remainingMilliliters))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(progressTint.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's hydration progress")
        .accessibilityValue(progressAccessibilityValue)
        .accessibilityHint("Shows consumed, goal, and remaining intake for today.")
    }

    private var progressLabel: String {
        let percentage = Int((progress * 100).rounded())
        return "\(percentage)% complete"
    }

    private var goalText: String {
        guard goalMilliliters > 0 else {
            return "Set goal"
        }

        return selectedUnit.format(milliliters: goalMilliliters)
    }

    private func todayMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressTint: Color {
        progress >= 1 ? AppTheme.success : AppTheme.accent
    }

    private var progressAccessibilityValue: String {
        let consumed = selectedUnit.format(milliliters: consumedMilliliters)
        let goal = goalText
        let remaining = selectedUnit.format(milliliters: remainingMilliliters)
        return "\(progressLabel). Consumed \(consumed). Goal \(goal). Remaining \(remaining)."
    }
}

#if DEBUG
    #Preview {
        TodayProgressCardView(
            consumedMilliliters: 1250,
            goalMilliliters: 2500,
            remainingMilliliters: 1250,
            progress: 0.5,
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
