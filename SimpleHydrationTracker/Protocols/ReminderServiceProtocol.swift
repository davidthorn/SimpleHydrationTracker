//
//  ReminderServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol ReminderServiceProtocol: Sendable {
    func observeAuthorizationStatus() async -> AsyncStream<ReminderAuthorizationStatus>
    func fetchAuthorizationStatus() async -> ReminderAuthorizationStatus
    func requestAuthorization() async throws -> ReminderAuthorizationStatus
    func updateSchedule(_ schedule: ReminderSchedule?) async throws
    func clearSchedule() async throws
}
