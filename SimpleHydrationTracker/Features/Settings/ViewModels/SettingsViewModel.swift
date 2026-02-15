//
//  SettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class SettingsViewModel: ObservableObject {
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var sipSize: SipSizeOption

    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let sipSizePreferenceService: SipSizePreferenceServiceProtocol
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?
    private var sipSizeObservationTask: Task<Void, Never>?

    internal init(
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        sipSizePreferenceService: SipSizePreferenceServiceProtocol
    ) {
        self.unitsPreferenceService = unitsPreferenceService
        self.sipSizePreferenceService = sipSizePreferenceService
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        sipSize = .ml30
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
        sipSizeObservationTask = Task {
            await observeSipSize()
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
        sipSizeObservationTask?.cancel()
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

    private func observeSipSize() async {
        let stream = await sipSizePreferenceService.observeSipSize()
        for await currentSipSize in stream {
            guard Task.isCancelled == false else {
                return
            }
            sipSize = currentSipSize
        }
    }
}
