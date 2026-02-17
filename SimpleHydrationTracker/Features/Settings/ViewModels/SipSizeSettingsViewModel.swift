//
//  SipSizeSettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models
import SimpleFramework

@MainActor
internal final class SipSizeSettingsViewModel: ObservableObject {
    @Published internal var selectedSipSize: SipSizeOption
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private let sipSizePreferenceService: SipSizePreferenceServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private var originalSipSize: SipSizeOption
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        sipSizePreferenceService: SipSizePreferenceServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol
    ) {
        self.sipSizePreferenceService = sipSizePreferenceService
        self.unitsPreferenceService = unitsPreferenceService
        selectedSipSize = .ml30
        selectedUnit = .milliliters
        errorMessage = nil
        isLoading = false
        originalSipSize = .ml30
        hasLoaded = false
    }

    internal var canSave: Bool {
        selectedSipSize != originalSipSize
    }

    internal var canReset: Bool {
        canSave
    }

    internal var canDelete: Bool {
        originalSipSize != .ml30
    }

    internal func loadIfNeeded() async {
        guard hasLoaded == false else {
            return
        }
        hasLoaded = true
        isLoading = true
        unitsObservationTask = Task {
            await observeUnits()
        }

        let currentSipSize = await sipSizePreferenceService.fetchSipSize()
        selectedSipSize = currentSipSize
        originalSipSize = currentSipSize
        errorMessage = nil
        isLoading = false
    }

    internal func save() async {
        await sipSizePreferenceService.updateSipSize(selectedSipSize)
        originalSipSize = selectedSipSize
        errorMessage = nil
    }

    internal func reset() {
        selectedSipSize = originalSipSize
        errorMessage = nil
    }

    internal func delete() async {
        await sipSizePreferenceService.resetSipSize()
        selectedSipSize = .ml30
        originalSipSize = .ml30
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
