//
//  DayDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI
import SimpleFramework

internal struct DayDetailView: View {
    @StateObject private var viewModel: DayDetailViewModel

    internal let dayID: HydrationDayIdentifier

    internal init(dayID: HydrationDayIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.dayID = dayID
        let vm = DayDetailViewModel(
            dayID: dayID,
            hydrationService: serviceContainer.hydrationService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TodayHeroCardComponent(
                        title: "Day Detail",
                        message: "Review every logged entry for this day.",
                        systemImage: "calendar.circle.fill",
                        tint: AppTheme.success
                    )

                    TodayStatusCardComponent(
                        title: "Daily Total",
                        message: viewModel.selectedUnit.format(milliliters: viewModel.totalMilliliters),
                        systemImage: "drop.fill",
                        tint: AppTheme.accent
                    )

                    if viewModel.entries.isEmpty {
                        TodayStatusCardComponent(
                            title: "No Entries Yet",
                            message: "No hydration entries were logged for this day.",
                            systemImage: "drop",
                            tint: AppTheme.warning
                        )
                    } else {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(
                                value: TodayRoute.editTodayEntry(
                                    entryID: HydrationEntryIdentifier(value: entry.id)
                                )
                            ) {
                                TodayDayEntryRowComponent(
                                    entry: entry,
                                    selectedUnit: viewModel.selectedUnit
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        TodayStatusCardComponent(
                            title: "Unable to Load Day",
                            message: errorMessage,
                            systemImage: "exclamationmark.triangle.fill",
                            tint: AppTheme.error
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Day Detail")
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            DayDetailView(
                dayID: HydrationDayIdentifier(value: Date()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
