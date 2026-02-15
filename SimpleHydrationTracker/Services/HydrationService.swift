//
//  HydrationService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal struct HydrationService: HydrationServiceProtocol {
    internal let hydrationStore: HydrationStoreProtocol

    internal init(hydrationStore: HydrationStoreProtocol) {
        self.hydrationStore = hydrationStore
    }

    internal func observeEntries() async throws -> AsyncStream<[HydrationEntry]> {
        try await hydrationStore.observeEntries()
    }

    internal func fetchEntries() async throws -> [HydrationEntry] {
        try await hydrationStore.fetchEntries()
    }

    internal func upsertEntry(_ entry: HydrationEntry) async throws {
        try await hydrationStore.upsertEntry(entry)
    }

    internal func deleteEntry(id: HydrationEntryIdentifier) async throws {
        try await hydrationStore.deleteEntry(id: id)
    }
}
