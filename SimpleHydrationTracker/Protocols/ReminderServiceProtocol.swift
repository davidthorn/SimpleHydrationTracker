//
//  ReminderServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol ReminderServiceProtocol: Sendable {
    func observeAuthorizationStatus() async -> AsyncStream<ReminderAuthorizationStatus>
    func observeSchedule() async -> AsyncStream<ReminderSchedule?>
    func fetchAuthorizationStatus() async -> ReminderAuthorizationStatus
    func fetchSchedule() async -> ReminderSchedule?
    func requestAuthorization() async throws -> ReminderAuthorizationStatus
    func updateSchedule(_ schedule: ReminderSchedule?) async throws
    func clearSchedule() async throws
}
