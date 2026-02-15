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
            Text("Quick Add")
                .font(.headline)

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
                        Text(selectedUnit.format(milliliters: amount.milliliters))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.blue.opacity(0.12))
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
                .fill(Color(.secondarySystemBackground))
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
    }
#endif
