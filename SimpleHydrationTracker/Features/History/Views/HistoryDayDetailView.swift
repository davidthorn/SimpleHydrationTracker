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
        List {
            Section("Summary") {
                Text("Total: \(viewModel.totalMilliliters) ml")
                Text("Entries: \(viewModel.entries.count)")
            }

            Section("Entries") {
                if viewModel.entries.isEmpty {
                    Text("No hydration entries for this day.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.entries) { entry in
                        NavigationLink(
                            value: HistoryRoute.entryDetail(entryID: HydrationEntryIdentifier(value: entry.id))
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(entry.amountMilliliters) ml")
                                    .font(.headline)
                                Text(entry.consumedAt.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
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
