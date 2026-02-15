//
//  HistoryDaySummary.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal struct HistoryDaySummary: Identifiable, Hashable {
    internal let dayID: HydrationDayIdentifier
    internal let date: Date
    internal let totalMilliliters: Int
    internal let entryCount: Int

    internal var id: HydrationDayIdentifier {
        dayID
    }

    internal init(
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
