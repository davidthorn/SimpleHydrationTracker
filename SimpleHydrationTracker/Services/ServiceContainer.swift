//
//  ServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import HealthKit
import Models
import SimpleFramework

internal struct ServiceContainer: ServiceContainerProtocol {
    internal let hydrationService: HydrationServiceProtocol
    internal let goalService: GoalServiceProtocol
    internal let reminderService: ReminderServiceProtocol
    internal let unitsPreferenceService: UnitsPreferenceServiceProtocol
    internal let sipSizePreferenceService: SipSizePreferenceServiceProtocol
    internal let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
    internal let healthKitHydrationService: HealthKitQuantitySyncServiceProtocol
    internal let hydrationEntrySyncMetadataService: HealthKitEntrySyncMetadataServiceProtocol

    internal init(
        hydrationStore: HydrationStoreProtocol = JSONEntityStore(
            fileName: "hydration_entries.json",
            sort: { lhs, rhs in
                lhs.consumedAt < rhs.consumedAt
            }
        ),
        goalStore: GoalStoreProtocol = JSONValueStore(fileName: "hydration_goal.json"),
        healthKitQuantityService: HealthKitQuantityServiceProtocol = HealthKitQuantityService(),
        hydrationEntrySyncMetadataStore: HealthKitEntrySyncMetadataStoreProtocol = HealthKitEntrySyncMetadataStore(
            fileName: "hydration_entry_sync_metadata.json"
        )
    ) {
        hydrationService = HydrationService(hydrationStore: hydrationStore)
        goalService = GoalService(goalStore: goalStore)
        reminderService = ReminderService(
            configuration: ReminderServiceConfiguration(
                identifierPrefix: "hydration.reminder",
                scheduleEnabledKey: "settings.reminder.schedule.enabled",
                scheduleStartHourKey: "settings.reminder.schedule.startHour",
                scheduleEndHourKey: "settings.reminder.schedule.endHour",
                scheduleIntervalKey: "settings.reminder.schedule.interval",
                notificationTitle: "Hydration Reminder",
                notificationBody: "Take a moment to log your water intake."
            )
        )
        unitsPreferenceService = UnitsPreferenceService(
            configuration: UnitsPreferenceServiceConfiguration(
                unitKey: "settings.volume.unit",
                defaultUnit: .milliliters
            )
        )
        sipSizePreferenceService = SipSizePreferenceService()
        historyFilterPreferenceService = HistoryFilterPreferenceService()
        healthKitHydrationService = HealthKitQuantitySyncService(
            descriptor: HealthKitQuantitySyncDescriptor(
                quantityIdentifier: .dietaryWater,
                providerIdentifier: "healthkit.dietaryWater",
                autoSyncKey: "hydration_healthkit_auto_sync_enabled"
            ),
            quantityService: healthKitQuantityService
        )
        hydrationEntrySyncMetadataService = HealthKitEntrySyncMetadataService(store: hydrationEntrySyncMetadataStore)
    }
}
