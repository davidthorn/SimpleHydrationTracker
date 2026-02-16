//
//  ServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct ServiceContainer: ServiceContainerProtocol {
    internal let hydrationService: HydrationServiceProtocol
    internal let goalService: GoalServiceProtocol
    internal let reminderService: ReminderServiceProtocol
    internal let unitsPreferenceService: UnitsPreferenceServiceProtocol
    internal let sipSizePreferenceService: SipSizePreferenceServiceProtocol
    internal let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
    internal let healthKitHydrationService: HealthKitHydrationServiceProtocol
    internal let hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol

    internal init(
        hydrationStore: HydrationStoreProtocol = HydrationStore(),
        goalStore: GoalStoreProtocol = GoalStore(),
        hydrationEntrySyncMetadataStore: HydrationEntrySyncMetadataStoreProtocol = HydrationEntrySyncMetadataStore()
    ) {
        hydrationService = HydrationService(hydrationStore: hydrationStore)
        goalService = GoalService(goalStore: goalStore)
        reminderService = ReminderService()
        unitsPreferenceService = UnitsPreferenceService()
        sipSizePreferenceService = SipSizePreferenceService()
        historyFilterPreferenceService = HistoryFilterPreferenceService()
        healthKitHydrationService = HealthKitHydrationService()
        hydrationEntrySyncMetadataService = HydrationEntrySyncMetadataService(store: hydrationEntrySyncMetadataStore)
    }
}
