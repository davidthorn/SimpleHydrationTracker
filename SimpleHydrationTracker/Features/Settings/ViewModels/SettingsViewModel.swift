//
//  SettingsViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation

@MainActor
internal final class SettingsViewModel: ObservableObject {
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var isLoading: Bool

    private var hasLoaded: Bool

    internal init() {
        errorMessage = nil
        isLoading = false
        hasLoaded = false
    }

    internal func start() async {
        guard hasLoaded == false else {
            return
        }

        hasLoaded = true
        isLoading = true
        errorMessage = nil
        isLoading = false
    }

    internal func presentPreferenceWriteError(_ message: String) {
        errorMessage = message
    }

    internal func clearError() {
        errorMessage = nil
    }
}
