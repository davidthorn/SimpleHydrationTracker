//
//  ReminderServiceError.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum ReminderServiceError: LocalizedError {
    case invalidSchedule
    case tooManyRequests
    case permissionDenied

    internal var errorDescription: String? {
        switch self {
        case .invalidSchedule:
            "Reminder schedule is invalid."
        case .tooManyRequests:
            "Reminder schedule creates too many notifications."
        case .permissionDenied:
            "Notification permission is required for reminders."
        }
    }
}
