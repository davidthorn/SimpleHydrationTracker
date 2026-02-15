//
//  TodayIntakeChartScale.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public enum TodayIntakeChartScale: Hashable, Sendable {
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case hourly

    public var minuteStrideCount: Int {
        switch self {
        case .fiveMinutes:
            return 5
        case .fifteenMinutes:
            return 15
        case .thirtyMinutes:
            return 30
        case .hourly:
            return 60
        }
    }

    public var bucketSeconds: TimeInterval {
        TimeInterval(minuteStrideCount * 60)
    }
}
