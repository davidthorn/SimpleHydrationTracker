//
//  UnitsPreferenceService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal actor UnitsPreferenceService: UnitsPreferenceServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let unitKey = "settings.volume.unit"
    private var continuations: [UUID: AsyncStream<SettingsVolumeUnit>.Continuation]

    internal init() {
        continuations = [:]
    }

    internal func observeUnit() async -> AsyncStream<SettingsVolumeUnit> {
        let streamPair = AsyncStream<SettingsVolumeUnit>.makeStream()
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

        let current = await fetchUnit()
        streamPair.continuation.yield(current)
        return streamPair.stream
    }

    internal func fetchUnit() async -> SettingsVolumeUnit {
        guard let rawValue = userDefaults.string(forKey: unitKey) else {
            return .milliliters
        }
        return SettingsVolumeUnit(rawValue: rawValue) ?? .milliliters
    }

    internal func updateUnit(_ unit: SettingsVolumeUnit) async {
        userDefaults.set(unit.rawValue, forKey: unitKey)
        publish(unit)
    }

    internal func resetUnit() async {
        userDefaults.removeObject(forKey: unitKey)
        publish(.milliliters)
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func publish(_ unit: SettingsVolumeUnit) {
        for continuation in continuations.values {
            continuation.yield(unit)
        }
    }
}
