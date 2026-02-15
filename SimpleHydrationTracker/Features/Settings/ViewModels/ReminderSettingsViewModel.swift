//
//  ReminderSettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation

@MainActor
internal final class ReminderSettingsViewModel: ObservableObject {
    @Published internal var isEnabled: Bool
    @Published internal var startHour: Int
    @Published internal var endHour: Int
    @Published internal var intervalMinutes: Int
    @Published internal private(set) var authorizationStatus: ReminderAuthorizationStatus
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private let reminderService: ReminderServiceProtocol
    private var originalSchedule: ReminderSchedule?
    private var hasLoaded: Bool

    internal init(reminderService: ReminderServiceProtocol) {
        self.reminderService = reminderService
        isEnabled = false
        startHour = 9
        endHour = 20
        intervalMinutes = 120
        authorizationStatus = .notDetermined
        errorMessage = nil
        isLoading = false
        originalSchedule = nil
        hasLoaded = false
    }

    internal var canSave: Bool {
        scheduleFromForm() != originalSchedule
    }

    internal var canReset: Bool {
        originalSchedule != nil && canSave
    }

    internal var canDelete: Bool {
        originalSchedule != nil
    }

    internal var isPermissionDenied: Bool {
        authorizationStatus == .denied
    }

    internal func start() async {
        guard hasLoaded == false else {
            return
        }

        hasLoaded = true
        isLoading = true

        authorizationStatus = await reminderService.fetchAuthorizationStatus()
        originalSchedule = await reminderService.fetchSchedule()
        applyScheduleToForm(originalSchedule)
        errorMessage = nil
        isLoading = false
    }

    internal func save() async throws {
        let schedule = scheduleFromForm()
        try await reminderService.updateSchedule(schedule)
        originalSchedule = schedule
        errorMessage = nil
    }

    internal func reset() {
        applyScheduleToForm(originalSchedule)
        errorMessage = nil
    }

    internal func delete() async throws {
        try await reminderService.clearSchedule()
        originalSchedule = nil
        applyScheduleToForm(nil)
        errorMessage = nil
    }

    internal func refreshPermissionStatus() async {
        authorizationStatus = await reminderService.fetchAuthorizationStatus()
    }

    internal func setError(_ message: String) {
        errorMessage = message
    }

    private func scheduleFromForm() -> ReminderSchedule? {
        guard isEnabled else {
            return nil
        }

        return ReminderSchedule(
            startHour: startHour,
            endHour: endHour,
            intervalMinutes: intervalMinutes,
            isEnabled: true
        )
    }

    private func applyScheduleToForm(_ schedule: ReminderSchedule?) {
        guard let schedule else {
            isEnabled = false
            startHour = 9
            endHour = 20
            intervalMinutes = 120
            return
        }

        isEnabled = schedule.isEnabled
        startHour = schedule.startHour
        endHour = schedule.endHour
        intervalMinutes = schedule.intervalMinutes
    }
}
