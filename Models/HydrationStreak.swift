//
//  HydrationStreak.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Streak statistics for goal completion.
public struct HydrationStreak: Codable, Identifiable, Hashable, Sendable {
    /// Stable unique identifier for the streak record.
    public let id: UUID

    /// Current consecutive days meeting the goal.
    public let currentDays: Int

    /// Best consecutive days meeting the goal.
    public let bestDays: Int

    /// Most recent date where goal was met.
    public let lastGoalMetDate: Date?

    /// Creates a streak record.
    public init(id: UUID, currentDays: Int, bestDays: Int, lastGoalMetDate: Date?) {
        self.id = id
        self.currentDays = currentDays
        self.bestDays = bestDays
        self.lastGoalMetDate = lastGoalMetDate
    }
}
