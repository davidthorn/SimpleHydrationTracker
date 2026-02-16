//
//  HealthKitHydrationPermissionState.swift
//  Models
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation

/// Read and write permission state for hydration HealthKit data.
public struct HealthKitHydrationPermissionState: Codable, Hashable, Sendable {
    /// Read permission state.
    public let read: HealthKitAuthorizationState
    /// Write permission state.
    public let write: HealthKitAuthorizationState

    /// Creates a hydration HealthKit permission state.
    public init(read: HealthKitAuthorizationState, write: HealthKitAuthorizationState) {
        self.read = read
        self.write = write
    }

    /// A state representing unsupported HealthKit access on this device.
    public static func unavailable() -> HealthKitHydrationPermissionState {
        HealthKitHydrationPermissionState(read: .unavailable, write: .unavailable)
    }
}
