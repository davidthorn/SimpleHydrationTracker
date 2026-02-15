//
//  DayDetailViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class DayDetailViewModel: ObservableObject {
    @Published internal private(set) var entries: [HydrationEntry]
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let dayID: HydrationDayIdentifier
    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let calendar: Calendar
    private var hasStarted: Bool
    private var entriesObservationTask: Task<Void, Never>?
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        dayID: HydrationDayIdentifier,
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.dayID = dayID
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        self.calendar = calendar
        entries = []
        errorMessage = nil
        selectedUnit = .milliliters
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

        unitsObservationTask = Task {
            await observeUnits()
        }
        entriesObservationTask = Task {
            await observeEntries()
        }
    }

    deinit {
        entriesObservationTask?.cancel()
        unitsObservationTask?.cancel()
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
                errorMessage = nil
            }
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errorMessage = "Unable to load entries for this day."
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
}
