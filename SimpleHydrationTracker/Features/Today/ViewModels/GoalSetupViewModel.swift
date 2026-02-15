//
//  GoalSetupViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class GoalSetupViewModel: ObservableObject {
    @Published internal var goalText: String
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool
    @Published internal private(set) var selectedUnit: SettingsVolumeUnit

    private let goalService: GoalServiceProtocol
    private let unitsPreferenceService: UnitsPreferenceServiceProtocol
    private let nowProvider: () -> Date
    private var originalGoal: HydrationGoal?
    private var hasLoaded: Bool
    private var unitsObservationTask: Task<Void, Never>?

    internal init(
        goalService: GoalServiceProtocol,
        unitsPreferenceService: UnitsPreferenceServiceProtocol,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.goalService = goalService
        self.unitsPreferenceService = unitsPreferenceService
        self.nowProvider = nowProvider
        goalText = ""
        errorMessage = nil
        isLoading = false
        selectedUnit = .milliliters
        originalGoal = nil
        hasLoaded = false
    }

    internal var hasPersistedGoal: Bool {
        originalGoal != nil
    }

    internal var hasChanges: Bool {
        guard hasPersistedGoal else {
            return goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }

        guard let originalGoal else {
            return false
        }

        guard let goalAmount = selectedUnit.parseAmountText(goalText) else {
            return true
        }

        return goalAmount != originalGoal.dailyTargetMilliliters
    }

    internal var canSave: Bool {
        guard selectedUnit.parseAmountText(goalText) != nil else {
            return false
        }
        return hasChanges
    }

    internal var canReset: Bool {
        hasPersistedGoal && hasChanges
    }

    internal var canDelete: Bool {
        hasPersistedGoal
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

    internal func saveGoal() async throws {
        guard let goalAmount = selectedUnit.parseAmountText(goalText) else {
            errorMessage = "Enter a valid goal greater than 0 \(selectedUnit.shortLabel)."
            return
        }

        let goal = HydrationGoal(
            id: originalGoal?.id ?? UUID(),
            dailyTargetMilliliters: goalAmount,
            updatedAt: nowProvider()
        )

        try await goalService.upsertGoal(goal)
        originalGoal = goal
        errorMessage = nil
    }

    internal func resetChanges() {
        guard let originalGoal else {
            return
        }

        goalText = selectedUnit.editableAmountText(milliliters: originalGoal.dailyTargetMilliliters)
        errorMessage = nil
    }

    internal func deleteGoal() async throws {
        guard originalGoal != nil else {
            return
        }

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

            let hadChanges = hasChanges
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
