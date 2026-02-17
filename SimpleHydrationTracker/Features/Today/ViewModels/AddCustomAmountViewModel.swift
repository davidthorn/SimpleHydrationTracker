//
//  AddCustomAmountViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import HealthKit
import Models
import SimpleFramework

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
    private let healthKitHydrationService: HealthKitQuantitySyncServiceProtocol
    private let hydrationEntrySyncMetadataService: HealthKitEntrySyncMetadataServiceProtocol
    private let nowProvider: () -> Date
    private var hasStarted: Bool
    private var unitsObservationTask: Task<Void, Never>?
    private var sipSizeObservationTask: Task<Void, Never>?

    internal init(
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        sipSizePreferenceService: SipSizePreferenceServiceProtocol,
        healthKitHydrationService: HealthKitQuantitySyncServiceProtocol,
        hydrationEntrySyncMetadataService: HealthKitEntrySyncMetadataServiceProtocol,
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
        let externalIdentifier = try await healthKitHydrationService.syncSampleIfEnabled(
            value: Double(entry.amountMilliliters),
            unit: .literUnit(with: .milli),
            start: entry.consumedAt,
            end: entry.consumedAt
        )
        if let externalIdentifier {
            let metadata = HealthKitEntrySyncMetadata(
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
