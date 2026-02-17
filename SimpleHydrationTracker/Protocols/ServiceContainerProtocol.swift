//
//  ServiceContainerProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import SimpleFramework

internal protocol ServiceContainerProtocol: Sendable {
    var hydrationService: HydrationServiceProtocol { get }
    var goalService: GoalServiceProtocol { get }
    var reminderService: ReminderServiceProtocol { get }
    var unitsPreferenceService: UnitsPreferenceServiceProtocol { get }
    var sipSizePreferenceService: SipSizePreferenceServiceProtocol { get }
    var historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol { get }
    var healthKitHydrationService: HealthKitQuantitySyncServiceProtocol { get }
    var hydrationEntrySyncMetadataService: HealthKitEntrySyncMetadataServiceProtocol { get }
}
