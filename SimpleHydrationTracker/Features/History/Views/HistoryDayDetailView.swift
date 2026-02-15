//
//  HistoryDayDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct HistoryDayDetailView: View {
    @StateObject private var viewModel: HistoryDayDetailViewModel

    internal let dayID: HydrationDayIdentifier

    internal init(dayID: HydrationDayIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.dayID = dayID
        let vm = HistoryDayDetailViewModel(dayID: dayID, hydrationService: serviceContainer.hydrationService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if viewModel.isLoading {
                        ProgressView("Loading day details...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    }

                    HistorySummaryCardComponent(
                        date: dayID.value,
                        totalMilliliters: viewModel.totalMilliliters,
                        entryCount: viewModel.entries.count
                    )

                    if let errorMessage = viewModel.errorMessage {
                        HistoryStatusCardComponent(
                            title: "Unable to Load Day",
                            message: errorMessage,
                            systemImage: "exclamationmark.triangle.fill",
                            tint: AppTheme.error
                        )
                    }

                    if viewModel.entries.isEmpty, viewModel.isLoading == false {
                        HistoryStatusCardComponent(
                            title: "No Entries",
                            message: "There are no hydration entries for this day.",
                            systemImage: "drop",
                            tint: AppTheme.accent
                        )
                    } else {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(
                                value: HistoryRoute.entryDetail(entryID: HydrationEntryIdentifier(value: entry.id))
                            ) {
                                HistoryEntryRowComponent(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
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
            HistoryDayDetailView(
                dayID: HydrationDayIdentifier(value: Date()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
