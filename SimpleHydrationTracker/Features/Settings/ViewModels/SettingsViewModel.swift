//
//  SettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation

@MainActor
internal final class SettingsViewModel: ObservableObject {
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(unitsPreferenceService: UnitsPreferenceServiceProtocol) {
        self.unitsPreferenceService = unitsPreferenceService
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        hasLoaded = false
    }

    internal func start() async {
        guard hasLoaded == false else {
            return
        }

        hasLoaded = true
        isLoading = true
        errorMessage = nil
        unitsObservationTask = Task {
            await observeUnits()
        }
        isLoading = false
    }

    internal func presentPreferenceWriteError(_ message: String) {
        errorMessage = message
    }

    internal func clearError() {
        errorMessage = nil
    }

    deinit {
        unitsObservationTask?.cancel()
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
