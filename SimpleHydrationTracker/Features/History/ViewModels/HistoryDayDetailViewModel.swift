//
//  HistoryDayDetailViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class HistoryDayDetailViewModel: ObservableObject {
    @Published internal private(set) var entries: [HydrationEntry]
    @Published internal private(set) var errorMessage: String?

    private let dayID: HydrationDayIdentifier
    private let hydrationService: HydrationServiceProtocol
    private let calendar: Calendar
    private var hasStarted: Bool

    internal init(
        dayID: HydrationDayIdentifier,
        hydrationService: HydrationServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.dayID = dayID
        self.hydrationService = hydrationService
        self.calendar = calendar
        entries = []
        errorMessage = nil
        hasStarted = false
    }

    internal var totalMilliliters: Int {
        entries.reduce(0) { partialResult, entry in
            partialResult + entry.amountMilliliters
        }
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }
        hasStarted = true

        do {
            let stream = try await hydrationService.observeEntries()
            for await allEntries in stream {
                guard Task.isCancelled == false else {
                    return
                }

                entries = allEntries
                    .filter { entry in
                        calendar.isDate(entry.consumedAt, inSameDayAs: dayID.value)
                    }
                    .sorted { $0.consumedAt > $1.consumedAt }
                errorMessage = nil
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errorMessage = "Unable to load day details."
        }
    }
}
