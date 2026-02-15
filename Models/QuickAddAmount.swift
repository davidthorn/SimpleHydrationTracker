//
//  QuickAddAmount.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Preset hydration amounts used for quick logging.
public enum QuickAddAmount: Int, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case ml150 = 150
    case ml250 = 250
    case ml350 = 350
    case ml500 = 500
    case ml650 = 650
    case ml750 = 750

    /// Stable identifier for list rendering.
    public var id: Int {
        rawValue
    }

    /// Amount represented in milliliters.
    public var milliliters: Int {
        rawValue
    }

    /// Short display label for UI.
    public var displayLabel: String {
        "+\(rawValue) ml"
    }
}
