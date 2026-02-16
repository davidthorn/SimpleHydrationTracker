//
//  HealthKitAuthorizationState.swift
//  Models
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation

/// Authorization state for a HealthKit read or write capability.
public enum HealthKitAuthorizationState: String, Codable, Sendable {
    case unavailable
    case notDetermined
    case authorized
    case denied

    /// Human-readable status label.
    public var displayText: String {
        switch self {
        case .unavailable:
            return "Unavailable"
        case .notDetermined:
            return "Not requested"
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        }
    }
}
