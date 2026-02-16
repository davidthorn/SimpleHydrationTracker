//
//  HydrationEntrySyncMetadataService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation
import Models

internal struct HydrationEntrySyncMetadataService: HydrationEntrySyncMetadataServiceProtocol {
    private let store: HydrationEntrySyncMetadataStoreProtocol

    internal init(store: HydrationEntrySyncMetadataStoreProtocol) {
        self.store = store
    }

    internal func observeMetadata() async throws -> AsyncStream<[HydrationEntrySyncMetadata]> {
        try await store.observeMetadata()
    }

    internal func fetchMetadata() async throws -> [HydrationEntrySyncMetadata] {
        try await store.fetchMetadata()
    }

    internal func fetchMetadata(for entryID: HydrationEntryIdentifier, providerIdentifier: String) async throws -> HydrationEntrySyncMetadata? {
        let metadata = try await store.fetchMetadata()
        return metadata.first {
            $0.entryID == entryID.value && $0.providerIdentifier == providerIdentifier
        }
    }

    internal func upsertMetadata(_ metadata: HydrationEntrySyncMetadata) async throws {
        try await store.upsertMetadata(metadata)
    }

    internal func deleteMetadata(for entryID: HydrationEntryIdentifier) async throws {
        try await store.deleteMetadata(for: entryID)
    }

    internal func deleteAllMetadata() async throws {
        try await store.deleteAllMetadata()
    }
}
