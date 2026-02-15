//
//  HistoryFilterPreferenceService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal actor HistoryFilterPreferenceService: HistoryFilterPreferenceServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let preferenceKey = "settings.history.filter.preferences"
    private var continuations: [UUID: AsyncStream<HistoryFilterPreferences>.Continuation]

    internal init() {
        continuations = [:]
    }

    internal func observePreferences() async -> AsyncStream<HistoryFilterPreferences> {
        let streamPair = AsyncStream<HistoryFilterPreferences>.makeStream()
        let id = UUID()
        continuations[id] = streamPair.continuation
        streamPair.continuation.onTermination = { [weak self] _ in
            guard let self else {
                return
            }
            Task {
                await self.removeContinuation(id: id)
            }
        }

        let current = await fetchPreferences()
        streamPair.continuation.yield(current)
        return streamPair.stream
    }

    internal func fetchPreferences() async -> HistoryFilterPreferences {
        guard
            let data = userDefaults.data(forKey: preferenceKey),
            let preferences = try? JSONDecoder().decode(HistoryFilterPreferences.self, from: data)
        else {
            return .default
        }

        return preferences
    }

    internal func updatePreferences(_ preferences: HistoryFilterPreferences) async {
        guard let encoded = try? JSONEncoder().encode(preferences) else {
            publish(.default)
            return
        }

        userDefaults.set(encoded, forKey: preferenceKey)
        publish(preferences)
    }

    internal func resetPreferences() async {
        userDefaults.removeObject(forKey: preferenceKey)
        publish(.default)
    }

    private func publish(_ preferences: HistoryFilterPreferences) {
        for continuation in continuations.values {
            continuation.yield(preferences)
        }
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
