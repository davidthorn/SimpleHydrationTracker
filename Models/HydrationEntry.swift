//
//  HydrationEntry.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// A single logged hydration event.
public struct HydrationEntry: Codable, Identifiable, Hashable, Sendable {
    /// Stable unique identifier for the entry.
    public let id: UUID

    /// Logged amount in milliliters.
    public let amountMilliliters: Int

    /// Timestamp for when the water was consumed.
    public let consumedAt: Date

    /// Source used to create this entry.
    public let source: HydrationEntrySource

    /// Creates a hydration entry.
    public init(
        id: UUID,
        amountMilliliters: Int,
        consumedAt: Date,
        source: HydrationEntrySource
    ) {
        self.id = id
        self.amountMilliliters = amountMilliliters
        self.consumedAt = consumedAt
        self.source = source
    }
}
