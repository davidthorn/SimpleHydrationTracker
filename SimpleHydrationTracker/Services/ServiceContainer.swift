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

    internal init(
        hydrationStore: HydrationStoreProtocol = HydrationStore(),
        goalStore: GoalStoreProtocol = GoalStore()
    ) {
        hydrationService = HydrationService(hydrationStore: hydrationStore)
        goalService = GoalService(goalStore: goalStore)
        reminderService = ReminderService()
    }
}
