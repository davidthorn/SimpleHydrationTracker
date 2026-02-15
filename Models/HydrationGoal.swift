//
//  HydrationGoal.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// User-configured daily hydration target.
public struct HydrationGoal: Codable, Identifiable, Hashable, Sendable {
    /// Stable unique identifier for the goal record.
    public let id: UUID

    /// Daily target amount in milliliters.
    public let dailyTargetMilliliters: Int

    /// Timestamp of the last goal update.
    public let updatedAt: Date

    /// Creates a hydration goal record.
    public init(id: UUID, dailyTargetMilliliters: Int, updatedAt: Date) {
        self.id = id
        self.dailyTargetMilliliters = dailyTargetMilliliters
        self.updatedAt = updatedAt
    }
}
