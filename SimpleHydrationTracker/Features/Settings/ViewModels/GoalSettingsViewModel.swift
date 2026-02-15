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

    private let goalService: GoalServiceProtocol
    private var originalGoal: HydrationGoal?
    private var hasLoaded: Bool

    internal init(goalService: GoalServiceProtocol) {
        self.goalService = goalService
        goalText = ""
        errorMessage = nil
        isLoading = false
        originalGoal = nil
        hasLoaded = false
    }

    internal var canSave: Bool {
        guard let goalValue = Int(goalText.trimmingCharacters(in: .whitespacesAndNewlines)), goalValue > 0 else {
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
        return goalText != String(originalGoal.dailyTargetMilliliters)
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

        do {
            let goal = try await goalService.fetchGoal()
            originalGoal = goal
            goalText = goal.map { String($0.dailyTargetMilliliters) } ?? ""
            errorMessage = nil
            isLoading = false
        } catch {
            errorMessage = "Unable to load goal settings."
            isLoading = false
        }
    }

    internal func save() async throws {
        guard let goalValue = Int(goalText.trimmingCharacters(in: .whitespacesAndNewlines)), goalValue > 0 else {
            errorMessage = "Enter a valid goal greater than 0 ml."
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
        goalText = originalGoal.map { String($0.dailyTargetMilliliters) } ?? ""
        errorMessage = nil
    }

    internal func delete() async throws {
        try await goalService.deleteGoal()
        originalGoal = nil
        goalText = ""
        errorMessage = nil
    }
}
