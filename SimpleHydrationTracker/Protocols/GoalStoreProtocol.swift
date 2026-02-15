//
//  GoalStoreProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal protocol GoalStoreProtocol: Sendable {
    func observeGoal() async throws -> AsyncStream<HydrationGoal?>
    func fetchGoal() async throws -> HydrationGoal?
    func upsertGoal(_ goal: HydrationGoal) async throws
    func deleteGoal() async throws
}
