//
//  DayDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

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
        List {
            Section("Summary") {
                Text("Total: \(viewModel.selectedUnit.format(milliliters: viewModel.totalMilliliters))")
            }

            Section("Entries") {
                if viewModel.entries.isEmpty {
                    Text("No hydration entries for this day.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.selectedUnit.format(milliliters: entry.amountMilliliters))
                                .font(.headline)
                            Text(entry.consumedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
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
            DayDetailView(
                dayID: HydrationDayIdentifier(value: Date()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
