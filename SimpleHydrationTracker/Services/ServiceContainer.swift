//
//  ServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct ServiceContainer: ServiceContainerProtocol {
    internal let hydrationStore: HydrationStoreProtocol
    internal let goalStore: GoalStoreProtocol

    internal init(
        hydrationStore: HydrationStoreProtocol = HydrationStore(),
        goalStore: GoalStoreProtocol = GoalStore()
    ) {
        self.hydrationStore = hydrationStore
        self.goalStore = goalStore
    }
}
