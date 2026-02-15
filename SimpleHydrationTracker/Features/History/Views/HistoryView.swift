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
        List {
            if viewModel.daySummaries.isEmpty {
                Text("No hydration history yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.daySummaries) { daySummary in
                    NavigationLink(value: HistoryRoute.dayDetail(dayID: daySummary.dayID)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(daySummary.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                            Text("\(daySummary.totalMilliliters) ml • \(daySummary.entryCount) entries")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: HistoryRoute.historyFilter) {
                    Text("Filter")
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
