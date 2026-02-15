//
//  TodayIntakeChartData.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct TodayIntakeChartData: Hashable, Sendable {
    public let points: [TodayIntakeChartPoint]
    public let scale: TodayIntakeChartScale

    public init(points: [TodayIntakeChartPoint], scale: TodayIntakeChartScale) {
        self.points = points
        self.scale = scale
    }

    public static func empty() -> TodayIntakeChartData {
        TodayIntakeChartData(points: [], scale: .hourly)
    }
}
