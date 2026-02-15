//
//  NotificationPermissionsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation

@MainActor
internal final class NotificationPermissionsViewModel: ObservableObject {
    @Published internal private(set) var status: ReminderAuthorizationStatus
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private let reminderService: ReminderServiceProtocol
    private var hasStarted: Bool

    internal init(reminderService: ReminderServiceProtocol) {
        self.reminderService = reminderService
        status = .notDetermined
        errorMessage = nil
        isLoading = false
        hasStarted = false
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }

        hasStarted = true
        isLoading = true

        let stream = await reminderService.observeAuthorizationStatus()
        for await nextStatus in stream {
            guard Task.isCancelled == false else {
                return
            }
            status = nextStatus
            isLoading = false
            errorMessage = nil
        }
    }

    internal func requestPermission() async {
        do {
            _ = try await reminderService.requestAuthorization()
            errorMessage = nil
        } catch {
            errorMessage = "Unable to request notification permission."
        }
    }

    internal func clearError() {
        errorMessage = nil
    }
}
