//
//  HistoryFilterPreferenceServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal protocol HistoryFilterPreferenceServiceProtocol: Sendable {
    func observePreferences() async -> AsyncStream<HistoryFilterPreferences>
    func fetchPreferences() async -> HistoryFilterPreferences
    func updatePreferences(_ preferences: HistoryFilterPreferences) async
    func resetPreferences() async
}
