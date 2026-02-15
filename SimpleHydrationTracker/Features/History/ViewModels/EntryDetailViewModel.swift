//
//  EntryDetailViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class EntryDetailViewModel: ObservableObject {
    @Published internal var amountText: String
    @Published internal var consumedAt: Date
    @Published internal private(set) var source: HydrationEntrySource?
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private let entryID: HydrationEntryIdentifier
    private let hydrationService: HydrationServiceProtocol
    private var originalEntry: HydrationEntry?
    private var hasLoaded: Bool

    internal init(entryID: HydrationEntryIdentifier, hydrationService: HydrationServiceProtocol) {
        self.entryID = entryID
        self.hydrationService = hydrationService
        amountText = ""
        consumedAt = Date()
        source = nil
        errorMessage = nil
        isLoading = false
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

        guard let amount = Int(amountText.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 else {
            return true
        }

        return amount != originalEntry.amountMilliliters || consumedAt != originalEntry.consumedAt
    }

    internal var canSave: Bool {
        guard hasPersistedEntry else {
            return false
        }

        guard let amount = Int(amountText.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 else {
            return false
        }

        let _ = amount
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

        do {
            let entries = try await hydrationService.fetchEntries()
            guard let entry = entries.first(where: { $0.id == entryID.value }) else {
                errorMessage = "Entry not found."
                isLoading = false
                return
            }

            originalEntry = entry
            amountText = String(entry.amountMilliliters)
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

        guard let amount = Int(amountText.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 else {
            errorMessage = "Enter a valid amount greater than 0 ml."
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

        amountText = String(originalEntry.amountMilliliters)
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
}
