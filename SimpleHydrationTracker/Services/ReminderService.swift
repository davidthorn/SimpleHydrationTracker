//
//  ReminderService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import UserNotifications

internal actor ReminderService: ReminderServiceProtocol {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let calendar = Calendar.current
    private let identifierPrefix = "hydration.reminder"
    private let maxScheduledRequests = 64
    private var authorizationContinuations: [UUID: AsyncStream<ReminderAuthorizationStatus>.Continuation]

    internal init() {
        authorizationContinuations = [:]
    }

    internal func observeAuthorizationStatus() async -> AsyncStream<ReminderAuthorizationStatus> {
        let streamPair = AsyncStream<ReminderAuthorizationStatus>.makeStream()
        let id = UUID()
        authorizationContinuations[id] = streamPair.continuation
        streamPair.continuation.onTermination = { [weak self] _ in
            guard let self else {
                return
            }
            Task {
                await self.removeContinuation(id: id)
            }
        }

        let status = await fetchAuthorizationStatus()
        streamPair.continuation.yield(status)
        return streamPair.stream
    }

    internal func fetchAuthorizationStatus() async -> ReminderAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        let status = mapAuthorizationStatus(settings.authorizationStatus)
        publishAuthorizationStatus(status)
        return status
    }

    internal func requestAuthorization() async throws -> ReminderAuthorizationStatus {
        _ = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        let status = await fetchAuthorizationStatus()
        return status
    }

    internal func updateSchedule(_ schedule: ReminderSchedule?) async throws {
        try await clearSchedule()

        guard let schedule else {
            return
        }

        guard schedule.isEnabled else {
            return
        }

        let permissionStatus = await fetchAuthorizationStatus()
        guard permissionStatus == .authorized || permissionStatus == .provisional else {
            throw ReminderServiceError.permissionDenied
        }

        let minutes = buildScheduleMinutes(from: schedule)
        guard minutes.isEmpty == false else {
            throw ReminderServiceError.invalidSchedule
        }
        guard minutes.count <= maxScheduledRequests else {
            throw ReminderServiceError.tooManyRequests
        }

        for minute in minutes {
            let hour = minute / 60
            let minuteOfHour = minute % 60

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minuteOfHour

            let content = UNMutableNotificationContent()
            content.title = "Hydration Reminder"
            content.body = "Take a moment to log your water intake."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(identifierPrefix).\(hour).\(minuteOfHour)",
                content: content,
                trigger: trigger
            )

            try await notificationCenter.add(request)
        }
    }

    internal func clearSchedule() async throws {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let reminderIdentifiers = pendingRequests.compactMap { request -> String? in
            if request.identifier.hasPrefix(identifierPrefix) {
                return request.identifier
            }
            return nil
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
    }

    private func removeContinuation(id: UUID) {
        authorizationContinuations.removeValue(forKey: id)
    }

    private func publishAuthorizationStatus(_ status: ReminderAuthorizationStatus) {
        for continuation in authorizationContinuations.values {
            continuation.yield(status)
        }
    }

    private func buildScheduleMinutes(from schedule: ReminderSchedule) -> [Int] {
        guard schedule.intervalMinutes > 0 else {
            return []
        }

        guard (0...23).contains(schedule.startHour), (0...23).contains(schedule.endHour) else {
            return []
        }

        let startMinute = schedule.startHour * 60
        let endMinute = schedule.endHour * 60
        guard startMinute < endMinute else {
            return []
        }

        var minutes: [Int] = []
        var currentMinute = startMinute

        while currentMinute < endMinute {
            let date = Date(timeIntervalSince1970: TimeInterval(currentMinute * 60))
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            minutes.append((hour * 60) + minute)
            currentMinute += schedule.intervalMinutes
        }

        return minutes
    }

    private func mapAuthorizationStatus(_ status: UNAuthorizationStatus) -> ReminderAuthorizationStatus {
        switch status {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized:
            .authorized
        case .provisional:
            .provisional
        case .ephemeral:
            .authorized
        @unknown default:
            .denied
        }
    }
}
