//
//  HistoryDaySummary.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct HistoryDaySummary: Identifiable, Hashable, Sendable {
    public let dayID: HydrationDayIdentifier
    public let date: Date
    public let totalMilliliters: Int
    public let entryCount: Int
    public let goalMilliliters: Int?

    public var id: HydrationDayIdentifier {
        dayID
    }

    public var didReachGoal: Bool? {
        guard let goalMilliliters, goalMilliliters > 0 else {
            return nil
        }
        return totalMilliliters >= goalMilliliters
    }

    public init(
        dayID: HydrationDayIdentifier,
        date: Date,
        totalMilliliters: Int,
        entryCount: Int,
        goalMilliliters: Int? = nil
    ) {
        self.dayID = dayID
        self.date = date
        self.totalMilliliters = totalMilliliters
        self.entryCount = entryCount
        self.goalMilliliters = goalMilliliters
    }
}
