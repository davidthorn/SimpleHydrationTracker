//
//  EditTodayEntryViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class EditTodayEntryViewModel: ObservableObject {
    private static let syncDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static func detailedErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        var lines: [String] = []
        lines.append("Type: \(String(reflecting: type(of: error)))")
        lines.append("Description: \(error.localizedDescription)")
        lines.append("Debug: \(String(reflecting: error))")
        lines.append("Domain: \(nsError.domain)")
        lines.append("Code: \(nsError.code)")

        if nsError.userInfo.isEmpty == false {
            lines.append("UserInfo: \(nsError.userInfo)")
        }

        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            lines.append("Underlying: \(String(reflecting: underlyingError))")
        }

        return lines.joined(separator: "\n")
    }

    @Published internal var amountText: String
    @Published internal var consumedAt: Date
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var syncMetadata: HydrationEntrySyncMetadata?
    @Published internal private(set) var healthKitPermissionState: HealthKitHydrationPermissionState
    @Published internal private(set) var isSyncingToHealthKit: Bool

    private let entryID: HydrationEntryIdentifier
    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let healthKitHydrationService: HealthKitHydrationServiceProtocol
    private let hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol
    private var originalEntry: HydrationEntry?
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        entryID: HydrationEntryIdentifier,
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        healthKitHydrationService: HealthKitHydrationServiceProtocol,
        hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol
    ) {
        self.entryID = entryID
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        self.healthKitHydrationService = healthKitHydrationService
        self.hydrationEntrySyncMetadataService = hydrationEntrySyncMetadataService
        amountText = ""
        consumedAt = Date()
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        syncMetadata = nil
        healthKitPermissionState = .unavailable()
        isSyncingToHealthKit = false
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

    internal var canSyncToHealthKit: Bool {
        hasPersistedEntry && healthKitPermissionState.write == .authorized
    }

    internal var syncStatusText: String {
        if let syncMetadata {
            return "Synced to HealthKit on \(Self.syncDateFormatter.string(from: syncMetadata.syncedAt))."
        }

        if healthKitPermissionState.write == .authorized {
            return "Not synced yet."
        }

        if healthKitPermissionState.write == .denied {
            return "HealthKit write permission denied."
        }

        if healthKitPermissionState.write == .notDetermined {
            return "HealthKit write permission not requested."
        }

        return "HealthKit is unavailable."
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
            healthKitPermissionState = await healthKitHydrationService.fetchPermissionState()
            let entries = try await hydrationService.fetchEntries()
            guard let entry = entries.first(where: { $0.id == entryID.value }) else {
                errorMessage = "Entry not found."
                isLoading = false
                return
            }

            originalEntry = entry
            amountText = selectedUnit.editableAmountText(milliliters: entry.amountMilliliters)
            consumedAt = entry.consumedAt
            syncMetadata = try await hydrationEntrySyncMetadataService.fetchMetadata(
                for: entryID,
                providerIdentifier: healthKitHydrationService.providerIdentifier
            )
            errorMessage = nil
            isLoading = false
        } catch {
            errorMessage = Self.detailedErrorMessage(error)
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

        let shouldInvalidateSyncMetadata = hasChanges
        let updatedEntry = HydrationEntry(
            id: originalEntry.id,
            amountMilliliters: amount,
            consumedAt: consumedAt,
            source: .edited
        )

        do {
            try await hydrationService.upsertEntry(updatedEntry)
            if shouldInvalidateSyncMetadata {
                try await hydrationEntrySyncMetadataService.deleteMetadata(for: entryID)
                syncMetadata = nil
            }
            self.originalEntry = updatedEntry
            errorMessage = nil
        } catch {
            errorMessage = Self.detailedErrorMessage(error)
            throw error
        }
    }

    internal func resetChanges() {
        guard let originalEntry else {
            return
        }

        amountText = selectedUnit.editableAmountText(milliliters: originalEntry.amountMilliliters)
        consumedAt = originalEntry.consumedAt
        errorMessage = nil
    }

    internal func deleteEntry() async throws {
        guard originalEntry != nil else {
            return
        }

        do {
            try await hydrationService.deleteEntry(id: entryID)
            try await hydrationEntrySyncMetadataService.deleteMetadata(for: entryID)
            originalEntry = nil
            syncMetadata = nil
            errorMessage = nil
        } catch {
            errorMessage = Self.detailedErrorMessage(error)
            throw error
        }
    }

    internal func refreshSyncStatus() async {
        healthKitPermissionState = await healthKitHydrationService.fetchPermissionState()

        guard hasPersistedEntry else {
            syncMetadata = nil
            return
        }

        do {
            syncMetadata = try await hydrationEntrySyncMetadataService.fetchMetadata(
                for: entryID,
                providerIdentifier: healthKitHydrationService.providerIdentifier
            )
        } catch {
            syncMetadata = nil
            errorMessage = Self.detailedErrorMessage(error)
        }
    }

    internal func syncPersistedEntryToHealthKit() async {
        guard let entry = originalEntry else { return }
        isSyncingToHealthKit = true
        defer { isSyncingToHealthKit = false }

        do {
            let externalIdentifier = try await healthKitHydrationService.syncEntry(entry)
            let metadata = HydrationEntrySyncMetadata(
                entryID: entryID.value,
                providerIdentifier: healthKitHydrationService.providerIdentifier,
                externalIdentifier: externalIdentifier,
                syncedAt: Date()
            )
            try await hydrationEntrySyncMetadataService.upsertMetadata(metadata)
            syncMetadata = metadata
            healthKitPermissionState = await healthKitHydrationService.fetchPermissionState()
            errorMessage = nil
        } catch {
            errorMessage = Self.detailedErrorMessage(error)
            healthKitPermissionState = await healthKitHydrationService.fetchPermissionState()
        }
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
