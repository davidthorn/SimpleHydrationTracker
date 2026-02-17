//
//  HealthKitSettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Combine
import Foundation
import SimpleFramework
import UIKit

@MainActor
internal final class HealthKitSettingsViewModel: ObservableObject {
    @Published internal private(set) var isHealthKitAvailable: Bool
    @Published internal private(set) var permissionState: HealthKitPermissionState
    @Published internal private(set) var isAutoSyncEnabled: Bool
    @Published internal private(set) var errorMessage: String?

    private let healthKitHydrationService: HealthKitQuantitySyncServiceProtocol

    internal init(serviceContainer: ServiceContainerProtocol) {
        healthKitHydrationService = serviceContainer.healthKitHydrationService
        isHealthKitAvailable = false
        permissionState = .unavailable()
        isAutoSyncEnabled = false
        errorMessage = nil
    }

    internal func load() async {
        isHealthKitAvailable = await healthKitHydrationService.isAvailable()
        permissionState = await healthKitHydrationService.fetchPermissionState()
        isAutoSyncEnabled = await healthKitHydrationService.fetchAutoSyncEnabled()
    }

    internal func observeAutoSync() async {
        let stream = await healthKitHydrationService.observeAutoSyncEnabled()
        for await snapshot in stream {
            isAutoSyncEnabled = snapshot
        }
    }

    internal func observeAppDidBecomeActive() async {
        let notifications = NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification)
        for await _ in notifications {
            if Task.isCancelled { return }
            permissionState = await healthKitHydrationService.fetchPermissionState()
        }
    }

    internal func requestPermissions() async {
        permissionState = await healthKitHydrationService.requestPermissions()
    }

    internal func setAutoSyncEnabled(_ isEnabled: Bool) async {
        await healthKitHydrationService.updateAutoSyncEnabled(isEnabled)
        isAutoSyncEnabled = isEnabled

        if isEnabled && permissionState.write != .authorized {
            permissionState = await healthKitHydrationService.requestPermissions()
            if permissionState.write != .authorized {
                errorMessage = "Enable Health permissions to save hydration entries into HealthKit."
            } else {
                errorMessage = nil
            }
        } else {
            errorMessage = nil
        }
    }

    internal var statusSummaryText: String {
        if isHealthKitAvailable == false {
            return "Health data is unavailable on this device."
        }

        if permissionState.read == .authorized && permissionState.write == .authorized {
            return "Read and write are authorized for dietary water."
        }

        if permissionState.read == .denied || permissionState.write == .denied {
            return "At least one permission is denied. Open Settings to update access."
        }

        return "Grant access to keep your hydration entries synced with HealthKit."
    }
}
