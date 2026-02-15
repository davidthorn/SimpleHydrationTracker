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
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let hydrationService: HydrationServiceProtocol
    private let goalService: GoalServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
    private let calendar: Calendar
    private var hasStarted: Bool
    private var hydrationObservationTask: Task<Void, Never>?
    private var goalObservationTask: Task<Void, Never>?
    private var unitsObservationTask: Task<Void, Never>?
    private var filterObservationTask: Task<Void, Never>?
    private var currentFilterPreferences: HistoryFilterPreferences
    private var latestEntries: [HydrationEntry]
    private var currentGoalMilliliters: Int?

    internal init(
        hydrationService: HydrationServiceProtocol,
        goalService: GoalServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.hydrationService = hydrationService
        self.goalService = goalService
        self.unitsPreferenceService = unitsPreferenceService
        self.historyFilterPreferenceService = historyFilterPreferenceService
        self.calendar = calendar
        daySummaries = []
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        currentFilterPreferences = .default
        latestEntries = []
        currentGoalMilliliters = nil
        hasStarted = false
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }
        hasStarted = true
        isLoading = true

        unitsObservationTask = Task {
            await observeUnits()
        }
        hydrationObservationTask = Task {
            await observeHistory()
        }
        goalObservationTask = Task {
            await observeGoal()
        }
        filterObservationTask = Task {
            await observeFilterPreferences()
        }
    }

    deinit {
        hydrationObservationTask?.cancel()
        goalObservationTask?.cancel()
        unitsObservationTask?.cancel()
        filterObservationTask?.cancel()
    }

    private func observeHistory() async {
        do {
            let stream = try await hydrationService.observeEntries()
            for await entries in stream {
                guard Task.isCancelled == false else {
                    return
                }

                latestEntries = entries
                daySummaries = projectDaySummaries(from: entries, preferences: currentFilterPreferences)
                errorMessage = nil
                isLoading = false
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errorMessage = "Unable to load hydration history."
            isLoading = false
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

    private func observeGoal() async {
        do {
            let stream = try await goalService.observeGoal()
            for await goal in stream {
                guard Task.isCancelled == false else {
                    return
                }
                currentGoalMilliliters = goal?.dailyTargetMilliliters
                daySummaries = projectDaySummaries(from: latestEntries, preferences: currentFilterPreferences)
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }
        }
    }

    private func observeFilterPreferences() async {
        let stream = await historyFilterPreferenceService.observePreferences()
        for await preferences in stream {
            guard Task.isCancelled == false else {
                return
            }
            currentFilterPreferences = preferences
            daySummaries = projectDaySummaries(from: latestEntries, preferences: preferences)
        }
    }

    private func projectDaySummaries(
        from entries: [HydrationEntry],
        preferences: HistoryFilterPreferences
    ) -> [HistoryDaySummary] {
        let filteredBySource = entries.filter { entry in
            switch entry.source {
            case .quickAdd:
                return preferences.includeQuickAdd
            case .customAmount:
                return preferences.includeCustomAmount
            case .edited:
                return preferences.includeEdited
            @unknown default:
                return true
            }
        }

        let filteredEntries = filteredBySource.filter { entry in
            isIncludedInDateRange(entry.consumedAt, selection: preferences.selection)
        }

        let groupedByDay = Dictionary(grouping: filteredEntries) { entry in
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
                entryCount: dayEntries.count,
                goalMilliliters: currentGoalMilliliters
            )
        }

        return summaries.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    private func isIncludedInDateRange(_ date: Date, selection: HistoryFilterSelection) -> Bool {
        switch selection {
        case .allTime:
            return true
        case .last7Days:
            return isWithinLastDays(date: date, days: 7)
        case .last30Days:
            return isWithinLastDays(date: date, days: 30)
        case .last90Days:
            return isWithinLastDays(date: date, days: 90)
        @unknown default:
            return true
        }
    }

    private func isWithinLastDays(date: Date, days: Int) -> Bool {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return true
        }
        return date >= startDate
    }
}
