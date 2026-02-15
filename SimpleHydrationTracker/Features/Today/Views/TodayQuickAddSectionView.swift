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
                Text("Small sip-based amounts and larger one-tap options.")
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
                            Image(systemName: symbolName(for: amount.milliliters))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.accent)
                            Text(selectedUnit.format(milliliters: amount.milliliters))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.accent)
                            Text(sizeDescription(for: amount.milliliters))
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
                    .accessibilityLabel("Quick add \(selectedUnit.format(milliliters: amount.milliliters))")
                    .accessibilityHint("\(sizeDescription(for: amount.milliliters)). Adds hydration instantly to today's total.")
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

    private func sizeDescription(for milliliters: Int) -> String {
        switch milliliters {
        case ..<40:
            return "Small sip"
        case ..<90:
            return "Sip"
        case ..<180:
            return "Big sip"
        case ..<320:
            return "Small glass"
        case ..<500:
            return "Glass"
        case ..<750:
            return "Large glass"
        default:
            return "Bottle"
        }
    }

    private func symbolName(for milliliters: Int) -> String {
        switch milliliters {
        case ..<40:
            return "drop"
        case ..<90:
            return "drop.fill"
        case ..<180:
            return "takeoutbag.and.cup.and.straw"
        case ..<320:
            return "wineglass"
        case ..<500:
            return "mug"
        case ..<750:
            return "mug.fill"
        default:
            return "waterbottle"
        }
    }
}

#if DEBUG
    #Preview {
        TodayQuickAddSectionView(
            quickAddOptions: [
                QuickAddAmount(milliliters: 30),
                QuickAddAmount(milliliters: 60),
                QuickAddAmount(milliliters: 90),
                QuickAddAmount(milliliters: 120),
                QuickAddAmount(milliliters: 250),
                QuickAddAmount(milliliters: 400),
                QuickAddAmount(milliliters: 600)
            ],
            selectedUnit: .milliliters
        ) { _ in }
            .padding()
            .background(AppTheme.pageGradient)
    }
#endif
