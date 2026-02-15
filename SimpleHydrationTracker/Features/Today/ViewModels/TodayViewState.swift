//
//  TodayViewState.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct TodayViewState {
    internal let date: Date
    internal let consumedMilliliters: Int
    internal let goalMilliliters: Int
    internal let remainingMilliliters: Int
    internal let progress: Double
    internal let errorMessage: String?

    internal init(
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

    internal static func loading(date: Date) -> TodayViewState {
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
