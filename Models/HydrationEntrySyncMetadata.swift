//
//  HydrationEntrySyncMetadata.swift
//  Models
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation

/// External synchronization record for a hydration entry.
public struct HydrationEntrySyncMetadata: Codable, Identifiable, Hashable, Sendable {
    /// Stable metadata identifier.
    public let id: UUID
    /// Source hydration entry identifier.
    public let entryID: UUID
    /// Provider identity (for example HealthKit dietary water).
    public let providerIdentifier: String
    /// External provider record identifier.
    public let externalIdentifier: String
    /// Timestamp when sync completed.
    public let syncedAt: Date

    /// Creates sync metadata for a hydration entry.
    public init(
        id: UUID = UUID(),
        entryID: UUID,
        providerIdentifier: String,
        externalIdentifier: String,
        syncedAt: Date
    ) {
        self.id = id
        self.entryID = entryID
        self.providerIdentifier = providerIdentifier
        self.externalIdentifier = externalIdentifier
        self.syncedAt = syncedAt
    }
}
