//
//  UnitsPreferenceServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol UnitsPreferenceServiceProtocol: Sendable {
    func observeUnit() async -> AsyncStream<SettingsVolumeUnit>
    func fetchUnit() async -> SettingsVolumeUnit
    func updateUnit(_ unit: SettingsVolumeUnit) async
    func resetUnit() async
}
