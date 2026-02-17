//
//  JSONEntityStore+HydrationStoreProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 17.02.2026.
//

import Foundation
import Models
import SimpleFramework

extension JSONEntityStore: HydrationStoreProtocol where Entity == HydrationEntry {
    internal func observeEntries() async throws -> AsyncStream<[HydrationEntry]> {
        try await observeEntities()
    }

    internal func fetchEntries() async throws -> [HydrationEntry] {
        try await fetchEntities()
    }

    internal func upsertEntry(_ entry: HydrationEntry) async throws {
        try await upsertEntity(entry)
    }

    internal func deleteEntry(id: HydrationEntryIdentifier) async throws {
        try await deleteEntity(id: id.value)
    }
}
