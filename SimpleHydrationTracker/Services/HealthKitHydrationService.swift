//
//  HealthKitHydrationService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation
import HealthKit
import Models

internal struct HealthKitHydrationService: HealthKitHydrationServiceProtocol {
    private static let didChangeAutoSyncNotification = Notification.Name("HealthKitHydrationService.didChangeAutoSync")

    private let autoSyncKey: String
    private let healthStore: HKHealthStore

    internal var providerIdentifier: String {
        "healthkit.dietaryWater"
    }

    internal init(
        autoSyncKey: String = "hydration_healthkit_auto_sync_enabled",
        healthStore: HKHealthStore = HKHealthStore()
    ) {
        self.autoSyncKey = autoSyncKey
        self.healthStore = healthStore
    }

    internal func isAvailable() async -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    internal func observeAutoSyncEnabled() async -> AsyncStream<Bool> {
        let streamPair = AsyncStream<Bool>.makeStream()
        let observationTask = Task {
            streamPair.continuation.yield(await fetchAutoSyncEnabled())

            let changes = NotificationCenter.default.notifications(named: Self.didChangeAutoSyncNotification)
            for await _ in changes {
                if Task.isCancelled { return }
                streamPair.continuation.yield(await fetchAutoSyncEnabled())
            }
        }

        streamPair.continuation.onTermination = { _ in
            observationTask.cancel()
        }

        return streamPair.stream
    }

    internal func fetchAutoSyncEnabled() async -> Bool {
        UserDefaults.standard.bool(forKey: autoSyncKey)
    }

    internal func updateAutoSyncEnabled(_ isEnabled: Bool) async {
        UserDefaults.standard.set(isEnabled, forKey: autoSyncKey)
        NotificationCenter.default.post(name: Self.didChangeAutoSyncNotification, object: nil)
    }

    internal func resetAutoSyncEnabled() async {
        UserDefaults.standard.removeObject(forKey: autoSyncKey)
        NotificationCenter.default.post(name: Self.didChangeAutoSyncNotification, object: nil)
    }

    internal func fetchPermissionState() async -> HealthKitHydrationPermissionState {
        guard await isAvailable() else {
            return .unavailable()
        }

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return .unavailable()
        }

        let writeState: HealthKitAuthorizationState
        switch healthStore.authorizationStatus(for: quantityType) {
        case .sharingAuthorized:
            writeState = .authorized
        case .sharingDenied:
            writeState = .denied
        case .notDetermined:
            writeState = .notDetermined
        @unknown default:
            writeState = .notDetermined
        }

        let readState = await resolveReadAuthorizationState(for: quantityType)
        return HealthKitHydrationPermissionState(read: readState, write: writeState)
    }

    internal func requestHydrationPermissions() async -> HealthKitHydrationPermissionState {
        guard await isAvailable() else {
            return .unavailable()
        }

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return .unavailable()
        }

        do {
            try await requestAuthorization(for: quantityType)
        } catch {
            // Return the latest resolvable state instead of failing the UI flow.
        }

        return await fetchPermissionState()
    }

    internal func syncEntryIfEnabled(_ entry: HydrationEntry) async throws -> String? {
        guard await isAvailable() else { return nil }
        guard await fetchAutoSyncEnabled() else { return nil }

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return nil
        }

        guard healthStore.authorizationStatus(for: quantityType) == .sharingAuthorized else {
            return nil
        }

        return try await saveEntryToHealthKit(entry, quantityType: quantityType)
    }

    internal func syncEntry(_ entry: HydrationEntry) async throws -> String {
        guard await isAvailable() else {
            throw NSError(domain: "HealthKitHydrationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data is unavailable on this device."])
        }

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            throw NSError(domain: "HealthKitHydrationService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Hydration type is unavailable in HealthKit."])
        }

        let permissionState = await fetchPermissionState()
        guard permissionState.write == .authorized else {
            throw NSError(domain: "HealthKitHydrationService", code: 3, userInfo: [NSLocalizedDescriptionKey: "HealthKit write access for hydration is not authorized."])
        }

        return try await saveEntryToHealthKit(entry, quantityType: quantityType)
    }

    private func saveEntryToHealthKit(_ entry: HydrationEntry, quantityType: HKQuantityType) async throws -> String {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(entry.amountMilliliters))
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: entry.consumedAt, end: entry.consumedAt)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.save(sample) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }

        return sample.uuid.uuidString
    }

    private func resolveReadAuthorizationState(for quantityType: HKQuantityType) async -> HealthKitAuthorizationState {
        let requestStatus = await fetchReadRequestStatus(for: quantityType)
        if requestStatus == .shouldRequest {
            return .notDetermined
        }

        let queryResult = await probeReadAuthorization(for: quantityType)
        switch queryResult {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .unavailable:
            return .unavailable
        @unknown default:
            return .notDetermined
        }
    }

    private func fetchReadRequestStatus(for quantityType: HKQuantityType) async -> HKAuthorizationRequestStatus {
        await withCheckedContinuation { continuation in
            healthStore.getRequestStatusForAuthorization(
                toShare: [quantityType],
                read: [quantityType]
            ) { status, _ in
                continuation.resume(returning: status)
            }
        }
    }

    private func probeReadAuthorization(for quantityType: HKQuantityType) async -> HealthKitAuthorizationState {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: [.strictStartDate]
            )
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, _, error in
                if let healthKitError = error as? HKError, healthKitError.code == .errorAuthorizationDenied {
                    continuation.resume(returning: .denied)
                    return
                }

                if error != nil {
                    continuation.resume(returning: .notDetermined)
                    return
                }

                continuation.resume(returning: .authorized)
            }

            healthStore.execute(query)
        }
    }

    private func requestAuthorization(for quantityType: HKQuantityType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(
                toShare: [quantityType],
                read: [quantityType]
            ) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }
}
