//
//  TodayIntakeChartPoint.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct TodayIntakeChartPoint: Hashable, Identifiable, Sendable {
    public let hourStart: Date
    public let totalMilliliters: Int

    public var id: Date {
        hourStart
    }

    public init(hourStart: Date, totalMilliliters: Int) {
        self.hourStart = hourStart
        self.totalMilliliters = totalMilliliters
    }
}
