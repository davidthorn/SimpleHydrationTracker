//
//  EntryDetailViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models
import SimpleFramework

@MainActor
internal final class EntryDetailViewModel: ObservableObject {
    @Published internal var amountText: String
    @Published internal var consumedAt: Date
    @Published internal private(set) var source: HydrationEntrySource?
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let entryID: HydrationEntryIdentifier
    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private var originalEntry: HydrationEntry?
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        entryID: HydrationEntryIdentifier,
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol
    ) {
        self.entryID = entryID
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        amountText = ""
        consumedAt = Date()
        source = nil
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        originalEntry = nil
        hasLoaded = false
    }

    internal var hasPersistedEntry: Bool {
        originalEntry != nil
    }

    internal var hasChanges: Bool {
        guard let originalEntry else {
            return false
        }

        guard let amount = selectedUnit.parseAmountText(amountText) else {
            return true
        }

        return amount != originalEntry.amountMilliliters || consumedAt != originalEntry.consumedAt
    }

    internal var canSave: Bool {
        guard hasPersistedEntry else {
            return false
        }

        guard selectedUnit.parseAmountText(amountText) != nil else {
            return false
        }
        return hasChanges
    }

    internal var canReset: Bool {
        hasPersistedEntry && hasChanges
    }

    internal var canDelete: Bool {
        hasPersistedEntry
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

        do {
            let entries = try await hydrationService.fetchEntries()
            guard let entry = entries.first(where: { $0.id == entryID.value }) else {
                errorMessage = "Entry not found."
                isLoading = false
                return
            }

            originalEntry = entry
            amountText = selectedUnit.editableAmountText(milliliters: entry.amountMilliliters)
            consumedAt = entry.consumedAt
            source = entry.source
            errorMessage = nil
            isLoading = false
        } catch {
            errorMessage = "Unable to load entry details."
            isLoading = false
        }
    }

    internal func saveChanges() async throws {
        guard let originalEntry else {
            errorMessage = "Entry not found."
            return
        }

        guard let amount = selectedUnit.parseAmountText(amountText) else {
            errorMessage = "Enter a valid amount greater than 0 \(selectedUnit.shortLabel)."
            return
        }

        let updatedEntry = HydrationEntry(
            id: originalEntry.id,
            amountMilliliters: amount,
            consumedAt: consumedAt,
            source: .edited
        )

        try await hydrationService.upsertEntry(updatedEntry)
        self.originalEntry = updatedEntry
        source = updatedEntry.source
        errorMessage = nil
    }

    internal func resetChanges() {
        guard let originalEntry else {
            return
        }

        amountText = selectedUnit.editableAmountText(milliliters: originalEntry.amountMilliliters)
        consumedAt = originalEntry.consumedAt
        source = originalEntry.source
        errorMessage = nil
    }

    internal func deleteEntry() async throws {
        guard originalEntry != nil else {
            return
        }

        try await hydrationService.deleteEntry(id: entryID)
        originalEntry = nil
        source = nil
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

            let hadChanges = hasChanges
            selectedUnit = unit

            guard hadChanges == false, let originalEntry else {
                continue
            }
            amountText = unit.editableAmountText(milliliters: originalEntry.amountMilliliters)
        }
    }
}
