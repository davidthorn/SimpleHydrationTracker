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
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var latestEntryID: HydrationEntryIdentifier?
    @Published internal private(set) var intakeChartData: TodayIntakeChartData

    private let hydrationService: HydrationServiceProtocol
    private let goalService: GoalServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let calendar: Calendar
    private let nowProvider: () -> Date
    private var isSubscribed: Bool
    private var hydrationObservationTask: Task<Void, Never>?
    private var goalObservationTask: Task<Void, Never>?
    private var unitsObservationTask: Task<Void, Never>?
    private var latestEntries: [HydrationEntry]
    private var latestGoalMilliliters: Int

    internal init(
        hydrationService: HydrationServiceProtocol,
        goalService: GoalServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        calendar: Calendar = .current,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.hydrationService = hydrationService
        self.goalService = goalService
        self.unitsPreferenceService = unitsPreferenceService
        self.calendar = calendar
        self.nowProvider = nowProvider
        state = .loading(date: nowProvider())
        selectedUnit = .milliliters
        latestEntryID = nil
        intakeChartData = .empty()
        isSubscribed = false
        latestEntries = []
        latestGoalMilliliters = 0
    }

    internal func start() async {
        guard isSubscribed == false else {
            return
        }
        isSubscribed = true

        unitsObservationTask = Task {
            await observeUnits()
        }
        hydrationObservationTask = Task {
            await observeHydrationEntries()
        }
        goalObservationTask = Task {
            await observeGoal()
        }
    }

    deinit {
        hydrationObservationTask?.cancel()
        goalObservationTask?.cancel()
        unitsObservationTask?.cancel()
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

    private func observeHydrationEntries() async {
        do {
            let stream = try await hydrationService.observeEntries()
            for await entries in stream {
                guard Task.isCancelled == false else {
                    return
                }

                latestEntries = entries
                refreshSummaryFromCache()
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

    private func observeGoal() async {
        do {
            let stream = try await goalService.observeGoal()
            for await goal in stream {
                guard Task.isCancelled == false else {
                    return
                }

                latestGoalMilliliters = goal?.dailyTargetMilliliters ?? 0
                refreshSummaryFromCache()
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
                errorMessage: "Unable to load today's goal."
            )
        }
    }

    private func observeUnits() async {
        let stream = await unitsPreferenceService.observeUnit()
        for await unit in stream {
            guard Task.isCancelled == false else {
                return
            }
            selectedUnit = unit
        }
    }

    private func refreshSummaryFromCache() {
        let now = nowProvider()
        let todaysEntries = latestEntries.filter { entry in
            calendar.isDate(entry.consumedAt, inSameDayAs: now)
        }

        let consumedMilliliters = todaysEntries.reduce(0) { partialResult, entry in
            partialResult + entry.amountMilliliters
        }
        let latestEntry = todaysEntries.sorted(by: { lhs, rhs in
            lhs.consumedAt > rhs.consumedAt
        }).first
        latestEntryID = latestEntry.map { entry in
            HydrationEntryIdentifier(value: entry.id)
        }
        intakeChartData = buildChartData(from: todaysEntries)

        let goalMilliliters = latestGoalMilliliters
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

    private func buildChartData(from entries: [HydrationEntry]) -> TodayIntakeChartData {
        guard entries.isEmpty == false else {
            return .empty()
        }

        let sortedEntries = entries.sorted(by: { lhs, rhs in
            lhs.consumedAt < rhs.consumedAt
        })
        let firstDate = sortedEntries.first?.consumedAt ?? nowProvider()
        let lastDate = sortedEntries.last?.consumedAt ?? firstDate
        let span = lastDate.timeIntervalSince(firstDate)
        let scale = chartScale(for: span)

        let groupedEntries = Dictionary(grouping: entries) { entry in
            bucketStartDate(for: entry.consumedAt, scale: scale)
        }

        let points = groupedEntries
            .map { bucketStart, grouped in
                let totalMilliliters = grouped.reduce(0) { partialResult, entry in
                    partialResult + entry.amountMilliliters
                }
                return TodayIntakeChartPoint(hourStart: bucketStart, totalMilliliters: totalMilliliters)
            }
            .sorted(by: { lhs, rhs in
                lhs.hourStart < rhs.hourStart
            })

        return TodayIntakeChartData(points: points, scale: scale)
    }

    private func chartScale(for span: TimeInterval) -> TodayIntakeChartScale {
        if span <= 2 * 60 * 60 {
            return .fiveMinutes
        }

        if span <= 6 * 60 * 60 {
            return .fifteenMinutes
        }

        if span <= 12 * 60 * 60 {
            return .thirtyMinutes
        }

        return .hourly
    }

    private func bucketStartDate(for date: Date, scale: TodayIntakeChartScale) -> Date {
        let bucketSeconds = scale.bucketSeconds
        let rawValue = date.timeIntervalSinceReferenceDate
        let bucketStart = floor(rawValue / bucketSeconds) * bucketSeconds
        return Date(timeIntervalSinceReferenceDate: bucketStart)
    }
}
