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
    private let onQuickAddTap: (QuickAddAmount) -> Void

    internal init(
        quickAddOptions: [QuickAddAmount],
        onQuickAddTap: @escaping (QuickAddAmount) -> Void
    ) {
        self.quickAddOptions = quickAddOptions
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
                        Text(amount.displayLabel)
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
        TodayQuickAddSectionView(quickAddOptions: QuickAddAmount.allCases) { _ in }
            .padding()
    }
#endif
