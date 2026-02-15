//
//  ReminderAuthorizationStatus.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum ReminderAuthorizationStatus: String, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}
