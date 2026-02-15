//
//  ReminderSchedule.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct ReminderSchedule: Hashable, Sendable {
    internal let startHour: Int
    internal let endHour: Int
    internal let intervalMinutes: Int
    internal let isEnabled: Bool

    nonisolated internal init(
        startHour: Int,
        endHour: Int,
        intervalMinutes: Int,
        isEnabled: Bool
    ) {
        self.startHour = startHour
        self.endHour = endHour
        self.intervalMinutes = intervalMinutes
        self.isEnabled = isEnabled
    }
}
