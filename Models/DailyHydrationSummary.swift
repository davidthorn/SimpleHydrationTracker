//
//  DailyHydrationSummary.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Daily hydration totals and progress values.
public struct DailyHydrationSummary: Codable, Hashable, Sendable {
    /// Day this summary represents.
    public let date: Date

    /// Daily target amount in milliliters.
    public let goalMilliliters: Int

    /// Total consumed amount for the day in milliliters.
    public let consumedMilliliters: Int

    /// Remaining amount for the day in milliliters.
    public let remainingMilliliters: Int

    /// Progress ratio from 0.0 to 1.0.
    public let progress: Double

    /// Whether consumed has met or exceeded the goal.
    public let isGoalMet: Bool

    /// Creates a daily summary.
    public init(
        date: Date,
        goalMilliliters: Int,
        consumedMilliliters: Int,
        remainingMilliliters: Int,
        progress: Double,
        isGoalMet: Bool
    ) {
        self.date = date
        self.goalMilliliters = goalMilliliters
        self.consumedMilliliters = consumedMilliliters
        self.remainingMilliliters = remainingMilliliters
        self.progress = progress
        self.isGoalMet = isGoalMet
    }
}
