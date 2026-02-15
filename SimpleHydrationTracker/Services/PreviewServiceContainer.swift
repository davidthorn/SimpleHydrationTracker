//
//  PreviewServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

#if DEBUG
    import Foundation
    import Models

    internal struct PreviewServiceContainer: ServiceContainerProtocol {
        internal let hydrationService: HydrationServiceProtocol
        internal let goalService: GoalServiceProtocol
        internal let reminderService: ReminderServiceProtocol
        internal let unitsPreferenceService: UnitsPreferenceServiceProtocol
        internal let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol

        internal init() {
            hydrationService = PreviewHydrationService()
            goalService = PreviewGoalService()
            reminderService = PreviewReminderService()
            unitsPreferenceService = PreviewUnitsPreferenceService()
            historyFilterPreferenceService = PreviewHistoryFilterPreferenceService()
        }
    }

    internal actor PreviewHydrationService: HydrationServiceProtocol {
        internal func observeEntries() async throws -> AsyncStream<[HydrationEntry]> {
            let streamPair = AsyncStream<[HydrationEntry]>.makeStream()
            streamPair.continuation.yield([])
            return streamPair.stream
        }

        internal func fetchEntries() async throws -> [HydrationEntry] {
            []
        }

        internal func upsertEntry(_ entry: HydrationEntry) async throws {}

        internal func deleteEntry(id: HydrationEntryIdentifier) async throws {}
    }

    internal actor PreviewGoalService: GoalServiceProtocol {
        internal func observeGoal() async throws -> AsyncStream<HydrationGoal?> {
            let streamPair = AsyncStream<HydrationGoal?>.makeStream()
            streamPair.continuation.yield(nil)
            return streamPair.stream
        }

        internal func fetchGoal() async throws -> HydrationGoal? {
            nil
        }

        internal func upsertGoal(_ goal: HydrationGoal) async throws {}

        internal func deleteGoal() async throws {}
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
#endif
