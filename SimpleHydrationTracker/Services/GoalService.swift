//
//  GoalService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal struct GoalService: GoalServiceProtocol {
    private let goalStore: GoalStoreProtocol

    internal init(goalStore: GoalStoreProtocol) {
        self.goalStore = goalStore
    }

    internal func observeGoal() async throws -> AsyncStream<HydrationGoal?> {
        try await goalStore.observeGoal()
    }

    internal func fetchGoal() async throws -> HydrationGoal? {
        try await goalStore.fetchGoal()
    }

    internal func upsertGoal(_ goal: HydrationGoal) async throws {
        try await goalStore.upsertGoal(goal)
    }

    internal func deleteGoal() async throws {
        try await goalStore.deleteGoal()
    }
}
