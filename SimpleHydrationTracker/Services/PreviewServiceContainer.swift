//
//  PreviewServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

#if DEBUG
    import Foundation
    import HealthKit
    import Models
    import SimpleFramework

    internal struct PreviewServiceContainer: ServiceContainerProtocol {
        internal let hydrationService: HydrationServiceProtocol
        internal let goalService: GoalServiceProtocol
        internal let reminderService: ReminderServiceProtocol
        internal let unitsPreferenceService: UnitsPreferenceServiceProtocol
        internal let sipSizePreferenceService: SipSizePreferenceServiceProtocol
        internal let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
        internal let healthKitHydrationService: HealthKitQuantitySyncServiceProtocol
        internal let hydrationEntrySyncMetadataService: HealthKitEntrySyncMetadataServiceProtocol

        internal init() {
            let previewHydrationStore = JSONEntityStore<HydrationEntry>(
                fileName: "preview_hydration_entries.json",
                sort: { lhs, rhs in
                    lhs.consumedAt < rhs.consumedAt
                }
            )
            let previewGoalStore = JSONValueStore<HydrationGoal>(fileName: "preview_hydration_goal.json")
            let previewSyncMetadataStore = HealthKitEntrySyncMetadataStore(fileName: "preview_hydration_entry_sync_metadata.json")
            let previewHealthKitQuantityService = HealthKitQuantityService()

            hydrationService = HydrationService(hydrationStore: previewHydrationStore)
            goalService = GoalService(goalStore: previewGoalStore)
            reminderService = PreviewReminderService()
            unitsPreferenceService = PreviewUnitsPreferenceService()
            sipSizePreferenceService = PreviewSipSizePreferenceService()
            historyFilterPreferenceService = PreviewHistoryFilterPreferenceService()
            healthKitHydrationService = HealthKitQuantitySyncService(
                descriptor: HealthKitQuantitySyncDescriptor(
                    quantityIdentifier: .dietaryWater,
                    providerIdentifier: "healthkit.dietaryWater",
                    autoSyncKey: "preview_hydration_healthkit_auto_sync_enabled"
                ),
                quantityService: previewHealthKitQuantityService
            )
            hydrationEntrySyncMetadataService = HealthKitEntrySyncMetadataService(store: previewSyncMetadataStore)
        }
    }

    internal actor PreviewReminderService: ReminderServiceProtocol {
        internal func observeAuthorizationStatus() async -> AsyncStream<ReminderAuthorizationStatus> {
            let streamPair = AsyncStream<ReminderAuthorizationStatus>.makeStream()
            streamPair.continuation.yield(.authorized)
            return streamPair.stream
        }

        internal func observeSchedule() async -> AsyncStream<ReminderSchedule?> {
            let streamPair = AsyncStream<ReminderSchedule?>.makeStream()
            streamPair.continuation.yield(
                ReminderSchedule(startHour: 9, endHour: 20, intervalMinutes: 120, isEnabled: true)
            )
            return streamPair.stream
        }

        internal func fetchAuthorizationStatus() async -> ReminderAuthorizationStatus {
            .authorized
        }

        internal func fetchSchedule() async -> ReminderSchedule? {
            ReminderSchedule(startHour: 9, endHour: 20, intervalMinutes: 120, isEnabled: true)
        }

        internal func requestAuthorization() async throws -> ReminderAuthorizationStatus {
            .authorized
        }

        internal func updateSchedule(_ schedule: ReminderSchedule?) async throws {}

        internal func clearSchedule() async throws {}
    }

    internal actor PreviewUnitsPreferenceService: UnitsPreferenceServiceProtocol {
        internal func observeUnit() async -> AsyncStream<SettingsVolumeUnit> {
            let streamPair = AsyncStream<SettingsVolumeUnit>.makeStream()
            streamPair.continuation.yield(.milliliters)
            return streamPair.stream
        }

        internal func fetchUnit() async -> SettingsVolumeUnit {
            .milliliters
        }

        internal func updateUnit(_ unit: SettingsVolumeUnit) async {}

        internal func resetUnit() async {}
    }

    internal actor PreviewHistoryFilterPreferenceService: HistoryFilterPreferenceServiceProtocol {
        internal func observePreferences() async -> AsyncStream<HistoryFilterPreferences> {
            let streamPair = AsyncStream<HistoryFilterPreferences>.makeStream()
            streamPair.continuation.yield(.default)
            return streamPair.stream
        }

        internal func fetchPreferences() async -> HistoryFilterPreferences {
            .default
        }

        internal func updatePreferences(_ preferences: HistoryFilterPreferences) async {}

        internal func resetPreferences() async {}
    }

    internal actor PreviewSipSizePreferenceService: SipSizePreferenceServiceProtocol {
        internal func observeSipSize() async -> AsyncStream<SipSizeOption> {
            let streamPair = AsyncStream<SipSizeOption>.makeStream()
            streamPair.continuation.yield(.ml30)
            return streamPair.stream
        }

        internal func fetchSipSize() async -> SipSizeOption {
            .ml30
        }

        internal func updateSipSize(_ sipSize: SipSizeOption) async {}

        internal func resetSipSize() async {}
    }
#endif
