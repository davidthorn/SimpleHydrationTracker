//
//  SettingsVolumeUnit.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum SettingsVolumeUnit: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case milliliters
    case ounces

    internal var id: String {
        rawValue
    }

    internal var title: String {
        switch self {
        case .milliliters:
            "Milliliters (ml)"
        case .ounces:
            "US Ounces (oz)"
        }
    }
}
