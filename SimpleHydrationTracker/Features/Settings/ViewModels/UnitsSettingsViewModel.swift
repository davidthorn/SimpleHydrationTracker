//
//  UnitsSettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import SimpleFramework

@MainActor
internal final class UnitsSettingsViewModel: ObservableObject {
    @Published internal var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private let unitsService: UnitsPreferenceServiceProtocol
    private var originalUnit: SettingsVolumeUnit
    private var hasLoaded: Bool

    internal init(unitsService: UnitsPreferenceServiceProtocol) {
        self.unitsService = unitsService
        selectedUnit = .milliliters
        originalUnit = .milliliters
        errorMessage = nil
        isLoading = false
        hasLoaded = false
    }

    internal var canSave: Bool {
        selectedUnit != originalUnit
    }

    internal var canReset: Bool {
        canSave
    }

    internal var canDelete: Bool {
        originalUnit != .milliliters
    }

    internal func loadIfNeeded() async {
        guard hasLoaded == false else {
            return
        }
        hasLoaded = true
        isLoading = true

        let currentUnit = await unitsService.fetchUnit()
        selectedUnit = currentUnit
        originalUnit = currentUnit
        errorMessage = nil
        isLoading = false
    }

    internal func save() async {
        await unitsService.updateUnit(selectedUnit)
        originalUnit = selectedUnit
        errorMessage = nil
    }

    internal func reset() {
        selectedUnit = originalUnit
        errorMessage = nil
    }

    internal func delete() async {
        await unitsService.resetUnit()
        selectedUnit = .milliliters
        originalUnit = .milliliters
        errorMessage = nil
    }
}
