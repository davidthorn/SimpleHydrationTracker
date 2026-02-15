//
//  TodayQuickAddSectionView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import Models

internal struct TodayQuickAddSectionView: View {
    private let quickAddOptions: [QuickAddAmount]
    private let selectedUnit: SettingsVolumeUnit
    private let onQuickAddTap: (QuickAddAmount) -> Void

    internal init(
        quickAddOptions: [QuickAddAmount],
        selectedUnit: SettingsVolumeUnit,
        onQuickAddTap: @escaping (QuickAddAmount) -> Void
    ) {
        self.quickAddOptions = quickAddOptions
        self.selectedUnit = selectedUnit
        self.onQuickAddTap = onQuickAddTap
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Add")
                    .font(.headline)
                Text("Tap once to log common amounts.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(quickAddOptions) { amount in
                    Button {
                        onQuickAddTap(amount)
                    } label: {
                        VStack(spacing: 2) {
                            Text(selectedUnit.format(milliliters: amount.milliliters))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.accent)
                            Text("Quick log")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppTheme.accent.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(AppTheme.accent.opacity(0.18), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.quickAdd.\(amount.milliliters)")
                }
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
}

#if DEBUG
    #Preview {
        TodayQuickAddSectionView(
            quickAddOptions: QuickAddAmount.allCases,
            selectedUnit: .milliliters
        ) { _ in }
            .padding()
            .background(AppTheme.pageGradient)
    }
#endif
