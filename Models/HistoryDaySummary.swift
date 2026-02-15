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

    public var id: HydrationDayIdentifier {
        dayID
    }

    public init(
        dayID: HydrationDayIdentifier,
        date: Date,
        totalMilliliters: Int,
        entryCount: Int
    ) {
        self.dayID = dayID
        self.date = date
        self.totalMilliliters = totalMilliliters
        self.entryCount = entryCount
    }
}
