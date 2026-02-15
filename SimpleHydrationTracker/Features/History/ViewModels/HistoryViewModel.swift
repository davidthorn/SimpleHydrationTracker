//
//  HistoryViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class HistoryViewModel: ObservableObject {
    @Published internal private(set) var daySummaries: [HistoryDaySummary]
    @Published internal private(set) var errorMessage: String?

    private let hydrationService: HydrationServiceProtocol
    private let calendar: Calendar
    private var hasStarted: Bool

    internal init(
        hydrationService: HydrationServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.hydrationService = hydrationService
        self.calendar = calendar
        daySummaries = []
        errorMessage = nil
        hasStarted = false
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }
        hasStarted = true

        do {
            let stream = try await hydrationService.observeEntries()
            for await entries in stream {
                guard Task.isCancelled == false else {
                    return
                }

                daySummaries = projectDaySummaries(from: entries)
                errorMessage = nil
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errorMessage = "Unable to load hydration history."
        }
    }

    private func projectDaySummaries(from entries: [HydrationEntry]) -> [HistoryDaySummary] {
        let groupedByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.consumedAt)
        }

        let summaries = groupedByDay.map { date, dayEntries in
            let totalMilliliters = dayEntries.reduce(0) { partialResult, entry in
                partialResult + entry.amountMilliliters
            }

            return HistoryDaySummary(
                dayID: HydrationDayIdentifier(value: date),
                date: date,
                totalMilliliters: totalMilliliters,
                entryCount: dayEntries.count
            )
        }

        return summaries.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }
}
