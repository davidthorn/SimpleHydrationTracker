//
//  AddCustomAmountViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class AddCustomAmountViewModel: ObservableObject {
    @Published internal var amountText: String
    @Published internal var consumedAt: Date
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit
    @Published internal private(set) var quickAddOptions: [QuickAddAmount]

    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let sipSizePreferenceService: SipSizePreferenceServiceProtocol
    private let healthKitHydrationService: HealthKitHydrationServiceProtocol
    private let hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol
    private let nowProvider: () -> Date
    private var hasStarted: Bool
    private var unitsObservationTask: Task<Void, Never>?
    private var sipSizeObservationTask: Task<Void, Never>?

    internal init(
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        sipSizePreferenceService: SipSizePreferenceServiceProtocol,
        healthKitHydrationService: HealthKitHydrationServiceProtocol,
        hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        self.sipSizePreferenceService = sipSizePreferenceService
        self.healthKitHydrationService = healthKitHydrationService
        self.hydrationEntrySyncMetadataService = hydrationEntrySyncMetadataService
        self.nowProvider = nowProvider
        amountText = ""
        consumedAt = nowProvider()
        errorMessage = nil
        selectedUnit = .milliliters
        quickAddOptions = QuickAddAmount.recommended(for: .ml30)
        hasStarted = false
    }

    internal var canSave: Bool {
        selectedUnit.parseAmountText(amountText) != nil
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }
        hasStarted = true
        unitsObservationTask = Task {
            await observeUnits()
        }
        sipSizeObservationTask = Task {
            await observeSipSize()
        }
    }

    internal func prefillAmount(using quickAddAmount: QuickAddAmount) {
        amountText = selectedUnit.editableAmountText(milliliters: quickAddAmount.milliliters)
        errorMessage = nil
    }

    internal func save() async throws {
        guard let amount = selectedUnit.parseAmountText(amountText) else {
            errorMessage = "Enter a valid amount greater than 0 \(selectedUnit.shortLabel)."
            return
        }

        let entry = HydrationEntry(
            id: UUID(),
            amountMilliliters: amount,
            consumedAt: consumedAt,
            source: .customAmount
        )

        try await hydrationService.upsertEntry(entry)
        let externalIdentifier = try await healthKitHydrationService.syncEntryIfEnabled(entry)
        if let externalIdentifier {
            let metadata = HydrationEntrySyncMetadata(
                entryID: entry.id,
                providerIdentifier: healthKitHydrationService.providerIdentifier,
                externalIdentifier: externalIdentifier,
                syncedAt: nowProvider()
            )
            try await hydrationEntrySyncMetadataService.upsertMetadata(metadata)
        }
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
        for await sipSize in stream {
            guard Task.isCancelled == false else {
                return
            }
            quickAddOptions = QuickAddAmount.recommended(for: sipSize)
        }
    }
}
