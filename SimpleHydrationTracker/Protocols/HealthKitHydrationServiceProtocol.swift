//
//  HealthKitHydrationServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation
import Models

internal protocol HealthKitHydrationServiceProtocol: Sendable {
    var providerIdentifier: String { get }
    func isAvailable() async -> Bool
    func observeAutoSyncEnabled() async -> AsyncStream<Bool>
    func fetchAutoSyncEnabled() async -> Bool
    func updateAutoSyncEnabled(_ isEnabled: Bool) async
    func resetAutoSyncEnabled() async

    func fetchPermissionState() async -> HealthKitHydrationPermissionState
    func requestHydrationPermissions() async -> HealthKitHydrationPermissionState

    func syncEntryIfEnabled(_ entry: HydrationEntry) async throws -> String?
    func syncEntry(_ entry: HydrationEntry) async throws -> String
}
