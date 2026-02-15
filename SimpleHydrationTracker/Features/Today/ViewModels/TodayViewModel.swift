//
//  TodayViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class TodayViewModel: ObservableObject {
    @Published internal private(set) var state: TodayViewState

    private let hydrationService: HydrationServiceProtocol
    private let goalService: GoalServiceProtocol
    private let calendar: Calendar
    private let nowProvider: () -> Date
    private var isSubscribed: Bool

    internal init(
        hydrationService: HydrationServiceProtocol,
        goalService: GoalServiceProtocol,
        calendar: Calendar = .current,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.hydrationService = hydrationService
        self.goalService = goalService
        self.calendar = calendar
        self.nowProvider = nowProvider
        state = .loading(date: nowProvider())
        isSubscribed = false
    }

    internal func start() async {
        guard isSubscribed == false else {
            return
        }
        isSubscribed = true

        do {
            let stream = try await hydrationService.observeEntries()
            for await entries in stream {
                guard Task.isCancelled == false else {
                    return
                }

                try await refreshSummary(entries: entries)
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            state = TodayViewState(
                date: nowProvider(),
                consumedMilliliters: state.consumedMilliliters,
                goalMilliliters: state.goalMilliliters,
                remainingMilliliters: state.remainingMilliliters,
                progress: state.progress,
                errorMessage: "Unable to load today's hydration data."
            )
        }
    }

    internal func addQuickAmount(_ quickAddAmount: QuickAddAmount) async throws {
        let entry = HydrationEntry(
            id: UUID(),
            amountMilliliters: quickAddAmount.milliliters,
            consumedAt: nowProvider(),
            source: .quickAdd
        )

        try await hydrationService.upsertEntry(entry)
    }

    private func refreshSummary(entries: [HydrationEntry]) async throws {
        let now = nowProvider()
        let todaysEntries = entries.filter { entry in
            calendar.isDate(entry.consumedAt, inSameDayAs: now)
        }

        let consumedMilliliters = todaysEntries.reduce(0) { partialResult, entry in
            partialResult + entry.amountMilliliters
        }

        let goal = try await goalService.fetchGoal()
        let goalMilliliters = goal?.dailyTargetMilliliters ?? 0
        let remainingMilliliters = max(goalMilliliters - consumedMilliliters, 0)

        let progress: Double
        if goalMilliliters > 0 {
            progress = min(Double(consumedMilliliters) / Double(goalMilliliters), 1)
        } else {
            progress = 0
        }

        state = TodayViewState(
            date: now,
            consumedMilliliters: consumedMilliliters,
            goalMilliliters: goalMilliliters,
            remainingMilliliters: remainingMilliliters,
            progress: progress,
            errorMessage: nil
        )
    }
}
