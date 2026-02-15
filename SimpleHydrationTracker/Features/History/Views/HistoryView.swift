//
//  HistoryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = HistoryViewModel(hydrationService: serviceContainer.hydrationService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if viewModel.isLoading {
                        ProgressView("Loading history...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        HistoryStatusCardComponent(
                            title: "Unable to Load History",
                            message: errorMessage,
                            systemImage: "exclamationmark.triangle.fill",
                            tint: AppTheme.error
                        )
                    }

                    if viewModel.daySummaries.isEmpty, viewModel.isLoading == false {
                        HistoryStatusCardComponent(
                            title: "No History Yet",
                            message: "Log water from Today and your daily history will appear here.",
                            systemImage: "drop",
                            tint: AppTheme.accent
                        )
                    } else {
                        ForEach(viewModel.daySummaries) { daySummary in
                            NavigationLink(value: HistoryRoute.dayDetail(dayID: daySummary.dayID)) {
                                HistoryDayRowComponent(summary: daySummary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: HistoryRoute.historyFilter) {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
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
            HistoryView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
