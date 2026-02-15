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
    public let firstEntryAt: Date?
    public let lastEntryAt: Date?
    public let averageMillilitersPerHour: Int?
    public let averageMillilitersPerEntry: Int?
    public let peakBucketStart: Date?
    public let peakBucketMilliliters: Int?
    public let intakeBuckets: [HistoryDayIntakeBucket]

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
        goalMilliliters: Int? = nil,
        firstEntryAt: Date? = nil,
        lastEntryAt: Date? = nil,
        averageMillilitersPerHour: Int? = nil,
        averageMillilitersPerEntry: Int? = nil,
        peakBucketStart: Date? = nil,
        peakBucketMilliliters: Int? = nil,
        intakeBuckets: [HistoryDayIntakeBucket] = []
    ) {
        self.dayID = dayID
        self.date = date
        self.totalMilliliters = totalMilliliters
        self.entryCount = entryCount
        self.goalMilliliters = goalMilliliters
        self.firstEntryAt = firstEntryAt
        self.lastEntryAt = lastEntryAt
        self.averageMillilitersPerHour = averageMillilitersPerHour
        self.averageMillilitersPerEntry = averageMillilitersPerEntry
        self.peakBucketStart = peakBucketStart
        self.peakBucketMilliliters = peakBucketMilliliters
        self.intakeBuckets = intakeBuckets
    }
}
