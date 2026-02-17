//
//  JSONValueStore+GoalStoreProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 17.02.2026.
//

import Foundation
import Models
import SimpleFramework

extension JSONValueStore: GoalStoreProtocol where Value == HydrationGoal {
    internal func observeGoal() async throws -> AsyncStream<HydrationGoal?> {
        try await observeValue()
    }

    internal func fetchGoal() async throws -> HydrationGoal? {
        try await fetchValue()
    }

    internal func upsertGoal(_ goal: HydrationGoal) async throws {
        try await upsertValue(goal)
    }

    internal func deleteGoal() async throws {
        try await deleteValue()
    }
}
