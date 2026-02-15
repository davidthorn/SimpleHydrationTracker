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

    private let hydrationService: HydrationServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let nowProvider: () -> Date
    private var hasStarted: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        hydrationService: HydrationServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.hydrationService = hydrationService
        self.unitsPreferenceService = unitsPreferenceService
        self.nowProvider = nowProvider
        amountText = ""
        consumedAt = nowProvider()
        errorMessage = nil
        selectedUnit = .milliliters
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
