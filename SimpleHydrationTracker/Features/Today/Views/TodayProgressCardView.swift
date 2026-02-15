//
//  TodayProgressCardView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayProgressCardView: View {
    private let consumedMilliliters: Int
    private let goalMilliliters: Int
    private let remainingMilliliters: Int
    private let progress: Double

    internal init(
        consumedMilliliters: Int,
        goalMilliliters: Int,
        remainingMilliliters: Int,
        progress: Double
    ) {
        self.consumedMilliliters = consumedMilliliters
        self.goalMilliliters = goalMilliliters
        self.remainingMilliliters = remainingMilliliters
        self.progress = progress
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Hydration")
                    .font(.headline)
                Text(progressLabel)
                    .font(.title2.weight(.semibold))
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.blue)

            HStack(spacing: 12) {
                todayMetric(title: "Consumed", value: "\(consumedMilliliters) ml")
                todayMetric(title: "Goal", value: goalText)
                todayMetric(title: "Remaining", value: "\(remainingMilliliters) ml")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var progressLabel: String {
        let percentage = Int((progress * 100).rounded())
        return "\(percentage)% complete"
    }

    private var goalText: String {
        guard goalMilliliters > 0 else {
            return "Set goal"
        }

        return "\(goalMilliliters) ml"
    }

    private func todayMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
    #Preview {
        TodayProgressCardView(
            consumedMilliliters: 1250,
            goalMilliliters: 2500,
            remainingMilliliters: 1250,
            progress: 0.5
        )
        .padding()
    }
#endif
