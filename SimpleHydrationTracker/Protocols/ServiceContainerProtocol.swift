//
//  ServiceContainerProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol ServiceContainerProtocol: Sendable {
    var hydrationService: HydrationServiceProtocol { get }
    var goalService: GoalServiceProtocol { get }
    var reminderService: ReminderServiceProtocol { get }
    var unitsPreferenceService: UnitsPreferenceServiceProtocol { get }
    var sipSizePreferenceService: SipSizePreferenceServiceProtocol { get }
    var historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol { get }
    var healthKitHydrationService: HealthKitHydrationServiceProtocol { get }
    var hydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol { get }
}
