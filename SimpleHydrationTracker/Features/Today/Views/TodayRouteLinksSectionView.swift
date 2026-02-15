//
//  TodayRouteLinksSectionView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct TodayRouteLinksSectionView: View {
    private let currentDayID: HydrationDayIdentifier
    private let latestEntryID: HydrationEntryIdentifier?

    internal init(currentDayID: HydrationDayIdentifier, latestEntryID: HydrationEntryIdentifier?) {
        self.currentDayID = currentDayID
        self.latestEntryID = latestEntryID
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("More")
                    .font(.headline)
                Text("Jump to detailed actions and configuration.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            NavigationLink(value: TodayRoute.addCustomAmount) {
                TodayRouteRowComponent(
                    title: "Add Custom Amount",
                    subtitle: "Log a specific intake",
                    systemImage: "plus.circle",
                    tint: AppTheme.accent
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.route.addCustomAmount")

            if let latestEntryID {
                NavigationLink(value: TodayRoute.editTodayEntry(entryID: latestEntryID)) {
                    TodayRouteRowComponent(
                        title: "Edit Latest Entry",
                        subtitle: "Update your most recent log",
                        systemImage: "pencil",
                        tint: AppTheme.warning
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.route.editLatestEntry")
            } else {
                TodayRouteRowComponent(
                    title: "Edit Latest Entry",
                    subtitle: "Add water first to enable editing",
                    systemImage: "pencil",
                    tint: AppTheme.warning,
                    isEnabled: false
                )
                .accessibilityIdentifier("today.route.editLatestEntry.disabled")
            }

            NavigationLink(value: TodayRoute.dayDetail(dayID: currentDayID)) {
                TodayRouteRowComponent(
                    title: "Day Detail",
                    subtitle: "Review today's timeline",
                    systemImage: "calendar",
                    tint: AppTheme.success
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.route.dayDetail")

            NavigationLink(value: TodayRoute.goalSetup) {
                TodayRouteRowComponent(
                    title: "Goal Setup",
                    subtitle: "Set your daily hydration target",
                    systemImage: "target",
                    tint: AppTheme.accent
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.route.goalSetup")
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
        NavigationStack {
            TodayRouteLinksSectionView(
                currentDayID: HydrationDayIdentifier(value: Date()),
                latestEntryID: HydrationEntryIdentifier(value: UUID())
            )
                .padding()
                .background(AppTheme.pageGradient)
        }
    }
#endif
