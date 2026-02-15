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
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let dayID: HydrationDayIdentifier
    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
    private let calendar: Calendar
    private var hasStarted: Bool
    private var entriesObservationTask: Task<Void, Never>?
    private var unitsObservationTask: Task<Void, Never>?
    private var filterObservationTask: Task<Void, Never>?
    private var currentFilterPreferences: HistoryFilterPreferences
    private var latestDayEntries: [HydrationEntry]

    internal init(
        dayID: HydrationDayIdentifier,
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.dayID = dayID
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        self.historyFilterPreferenceService = historyFilterPreferenceService
        self.calendar = calendar
        entries = []
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        currentFilterPreferences = .default
        latestDayEntries = []
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
        isLoading = true

        unitsObservationTask = Task {
            await observeUnits()
        }
        entriesObservationTask = Task {
            await observeEntries()
        }
        filterObservationTask = Task {
            await observeFilterPreferences()
        }
    }

    deinit {
        entriesObservationTask?.cancel()
        unitsObservationTask?.cancel()
        filterObservationTask?.cancel()
    }

    private func observeEntries() async {
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
                latestDayEntries = entries
                entries = applySourceFilter(to: latestDayEntries, preferences: currentFilterPreferences)
                errorMessage = nil
                isLoading = false
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errorMessage = "Unable to load day details."
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

    private func observeFilterPreferences() async {
        let stream = await historyFilterPreferenceService.observePreferences()
        for await preferences in stream {
            guard Task.isCancelled == false else {
                return
            }
            currentFilterPreferences = preferences
            entries = applySourceFilter(to: latestDayEntries, preferences: preferences)
        }
    }

    private func applySourceFilter(
        to entries: [HydrationEntry],
        preferences: HistoryFilterPreferences
    ) -> [HydrationEntry] {
        entries.filter { entry in
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
    }
}
