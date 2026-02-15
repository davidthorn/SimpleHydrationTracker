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

    internal var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(summary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(summary.entryCount) entries")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            Text("\(summary.totalMilliliters) ml")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppTheme.accent.opacity(0.12))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
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
            )
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
