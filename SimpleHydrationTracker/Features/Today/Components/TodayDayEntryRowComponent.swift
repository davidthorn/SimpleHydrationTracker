//
//  TodayDayEntryRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SimpleFramework
import SwiftUI

internal struct TodayDayEntryRowComponent: View {
    internal let entry: HydrationEntry
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName(for: entry.amountMilliliters))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(AppTheme.accent.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(selectedUnit.format(milliliters: entry.amountMilliliters))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(intakeDescription(for: entry.amountMilliliters))
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                Text(entry.consumedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration entry")
        .accessibilityValue(
            "\(selectedUnit.format(milliliters: entry.amountMilliliters)), \(intakeDescription(for: entry.amountMilliliters)), \(entry.consumedAt.formatted(date: .abbreviated, time: .shortened))"
        )
        .accessibilityHint("Opens entry details.")
    }

    private func intakeDescription(for milliliters: Int) -> String {
        switch milliliters {
        case ..<40:
            return "Small sip intake"
        case ..<90:
            return "Sip intake"
        case ..<180:
            return "Big sip intake"
        case ..<320:
            return "Small glass intake"
        case ..<500:
            return "Glass intake"
        case ..<750:
            return "Large glass intake"
        default:
            return "Bottle intake"
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
        TodayDayEntryRowComponent(
            entry: HydrationEntry(
                id: UUID(),
                amountMilliliters: 350,
                consumedAt: Date(),
                source: .quickAdd
            ),
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
