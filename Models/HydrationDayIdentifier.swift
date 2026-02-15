//
//  HydrationDayIdentifier.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Shared day identifier payload for route-safe day navigation.
public struct HydrationDayIdentifier: Codable, Hashable, Sendable {
    /// Backing day date value.
    public let value: Date

    /// Creates a day identifier payload.
    public init(value: Date) {
        self.value = value
    }
}
