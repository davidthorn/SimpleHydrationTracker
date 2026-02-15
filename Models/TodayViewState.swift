//
//  TodayViewState.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct TodayViewState: Hashable, Sendable {
    public let date: Date
    public let consumedMilliliters: Int
    public let goalMilliliters: Int
    public let remainingMilliliters: Int
    public let progress: Double
    public let errorMessage: String?

    public init(
        date: Date,
        consumedMilliliters: Int,
        goalMilliliters: Int,
        remainingMilliliters: Int,
        progress: Double,
        errorMessage: String?
    ) {
        self.date = date
        self.consumedMilliliters = consumedMilliliters
        self.goalMilliliters = goalMilliliters
        self.remainingMilliliters = remainingMilliliters
        self.progress = progress
        self.errorMessage = errorMessage
    }

    public static func loading(date: Date) -> TodayViewState {
        TodayViewState(
            date: date,
            consumedMilliliters: 0,
            goalMilliliters: 0,
            remainingMilliliters: 0,
            progress: 0,
            errorMessage: nil
        )
    }
}
