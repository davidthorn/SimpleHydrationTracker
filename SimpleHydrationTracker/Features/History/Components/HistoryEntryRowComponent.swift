//
//  HistoryEntryRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct HistoryEntryRowComponent: View {
    internal let entry: HydrationEntry

    internal var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.amountMilliliters) ml")
                    .font(.headline)
                Text(entry.consumedAt.formatted(date: .omitted, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            Text(entry.source.displayTitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
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
        HistoryEntryRowComponent(
            entry: HydrationEntry(
                id: UUID(),
                amountMilliliters: 350,
                consumedAt: Date(),
                source: .quickAdd
            )
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
