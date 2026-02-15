//
//  GoalSettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class GoalSettingsViewModel: ObservableObject {
    @Published internal var goalText: String
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let goalService: GoalServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private var originalGoal: HydrationGoal?
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        goalService: GoalServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol
    ) {
        self.goalService = goalService
        self.unitsPreferenceService = unitsPreferenceService
        goalText = ""
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        originalGoal = nil
        hasLoaded = false
    }

    internal var canSave: Bool {
        guard let goalValue = selectedUnit.parseAmountText(goalText) else {
            return false
        }

        if let originalGoal {
            return originalGoal.dailyTargetMilliliters != goalValue
        }

        return true
    }

    internal var canReset: Bool {
        guard let originalGoal else {
            return false
        }
        return goalText != selectedUnit.editableAmountText(milliliters: originalGoal.dailyTargetMilliliters)
    }

    internal var canDelete: Bool {
        originalGoal != nil
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
            let goal = try await goalService.fetchGoal()
            originalGoal = goal
            goalText = goal.map { selectedUnit.editableAmountText(milliliters: $0.dailyTargetMilliliters) } ?? ""
            errorMessage = nil
            isLoading = false
        } catch {
            errorMessage = "Unable to load goal settings."
            isLoading = false
        }
    }

    internal func save() async throws {
        guard let goalValue = selectedUnit.parseAmountText(goalText) else {
            errorMessage = "Enter a valid goal greater than 0 \(selectedUnit.shortLabel)."
            return
        }

        let goalID = originalGoal?.id ?? UUID()
        let goal = HydrationGoal(
            id: goalID,
            dailyTargetMilliliters: goalValue,
            updatedAt: Date()
        )

        try await goalService.upsertGoal(goal)
        originalGoal = goal
        errorMessage = nil
    }

    internal func reset() {
        goalText = originalGoal.map { selectedUnit.editableAmountText(milliliters: $0.dailyTargetMilliliters) } ?? ""
        errorMessage = nil
    }

    internal func delete() async throws {
        try await goalService.deleteGoal()
        originalGoal = nil
        goalText = ""
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

            let hadChanges = canSave || canReset
            selectedUnit = unit

            guard hadChanges == false else {
                continue
            }

            if let originalGoal {
                goalText = unit.editableAmountText(milliliters: originalGoal.dailyTargetMilliliters)
            } else {
                goalText = ""
            }
        }
    }
}
